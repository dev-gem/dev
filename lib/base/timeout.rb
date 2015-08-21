puts __FILE__ if defined?(DEBUG)

############################################################################
# The following code is based on code originally copied from 
# https://gist.github.com/lpar/1032297
# Gist title: lpar/timeout.rb
############################################################################
# Runs a specified shell command in a separate thread.
# If it exceeds the given timeout in seconds, kills it.
# Returns any output produced by the command (stdout or stderr) as a String.
# Uses Kernel.select to wait up to the tick length (in seconds) between 
# checks on the command's status
#
# If you've got a cleaner way of doing this, I'd be interested to see it.
# If you think you can do it with Ruby's Timeout module, think again.
def run_with_timeout(directory,command, timeout, tick)
  output = ''
  exit_code=1
  begin
    # Start task in another thread, which spawns a process
    stdin, stderrout, thread = Open3.popen2e(command, :chdir=>directory)
    # Get the pid of the spawned process
    pid = thread[:pid]
    start = Time.now

    while (Time.now - start) < timeout and thread.alive?
      # Wait up to `tick` seconds for output/error data
      Kernel.select([stderrout], nil, nil, tick)
      # Try to read the data
      begin
        output << stderrout.read_nonblock(BUFFER_SIZE)
      rescue IO::WaitReadable
        # A read would block, so loop around for another select
      rescue EOFError
        # Command has completed, not really an error...
        break
      end
    end

    # Give Ruby time to clean up the other thread
    sleep 1

    if thread.alive?
      # We need to kill the process, because killing the thread leaves
      # the process alive but detached, annoyingly enough.
      Process.kill("TERM", pid)
    else
      exit_code=thread.value
      sleep 1
    end

  ensure
    stdin.close if stdin
    stderrout.close if stderrout
  end
  return [output,exit_code]
end

require 'timeout'
def run_with_timeout2(directory,command,timeout)
  # stdout, stderr pipes
  rout, wout = IO.pipe
  rerr, werr = IO.pipe
  output=''
  error=''
  exit_code=1
  pid = Process.spawn(command, :chdir => directory, :out => wout, :err => werr)
  begin
    Timeout.timeout(timeout) do
      exit_code = Process.wait2(pid)
      output = rout.readlines.join("\n")
      error = rerr.readlines.join("\n")
    end
  rescue
    Proces.kill('TERM',pid)
    output = output + 'timeout occurred.'
  ensure
    rout.close
    rerr.close
  end
  [output,exit_code]
end

