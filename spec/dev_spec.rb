# frozen_string_literal: true

require_relative("../lib/dev")

describe Dev do
  it "should fail when passed an unrecognized argument" do
    dev = Dev.new({ "SUPPRESS_CONSOLE_OUTPUT" => "true" })
    expect(dev.execute("unknown")).to eq(1)
    expect(dev.env.output.include?("unknown command")).to eq true
  end

  it "should display usage when no args are passed to execute" do
    dev = Dev.new({ "SUPPRESS_CONSOLE_OUTPUT" => "true" })
    expect(dev.execute("")).to eq(0)
  end

  it "should be able to perform add, work, make, remove for a specific project" do
    dir = "#{File.dirname(__FILE__)}/dev_spec"
    Dir.remove dir
    Dir.make dir
    dev = Dev.new({ "DEV_ROOT" => dir, "SUPPRESS_CONSOLE_OUTPUT" => "true" })

    # INIT REPO HelloRake.git
    Dir.chdir(dir) do
      cmd = Command.execute("git init --bare HelloRake.git")
      cmd = Command.execute("git clone \"#{dir}/HelloRake.git\"")
      Dir.chdir("#{dir}/HelloRake") do
        File.open("rakefile.rb", "w") { |f| f.puts 'task :default do; puts "ok"; end' }
        # cmd=Command.execute('git config user.email "lou-parslow+dev.gem@gamail.com"') if Git.user_email.length < 1
        # cmd=Command.execute('git config user.name "lou-parslow"') if Git.user_name.length < 1
        # cmd=Command.execute('git config --global push.default simple')
        # cmd=Command.execute('git add rakefile.rb')
        # cmd=Command.execute('git commit -m"added rakefile.rb"')
        # cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
        # cmd=Command.execute('git push')
        # cmd=Command.execute('git push --tags')
      end
    end

    unless dir.include?(" ")
      # ADD
      # dev.execute("add \"#{dir}/HelloRake.git\" local/HelloRake")

      # dev.env.output=''
      # expect(dev.execute("list HelloRake")).to eq 0
      # expect(dev.env.output.include?('HelloRake')).to eq true

      # WORK
      # expect(dev.execute('work HelloRake')).to eq 0
      # dev.env.output=''

      # MAKE
      # expect(dev.execute('make HelloRake')).to eq 0

      # REMOVE
      # expect(dev.execute('remove HelloRake')).to eq 0
    end

    Dir.remove dir
  end

  it "should be able to perform work and make timeouts for infinite loop project" do
    dir = "#{File.dirname(__FILE__)}/dev_spec"
    Dir.remove dir
    Dir.make dir
    dev = Dev.new({ "DEV_ROOT" => dir, "SUPPRESS_CONSOLE_OUTPUT" => "true" })

    # INIT REPO HelloRake.git
    sleep(1)
    Dir.chdir(dir) do
      cmd = Command.execute("git init --bare HelloRake.git")
      cmd = Command.execute("git clone \"#{dir}/HelloRake.git\"")
      Dir.chdir("#{dir}/HelloRake") do
        File.open("rakefile.rb", "w") { |f| f.puts "task :default do; while(true do; sleep(60);puts 'x';end; end" }
        # cmd=Command.execute('git config user.email "lou-parslow+dev.gem@gamail.com"') if Git.user_email.length < 1
        # cmd=Command.execute('git config user.name "lou-parslow"') if Git.user_name.length < 1
        # cmd=Command.execute('git config --global push.default simple')
        # cmd=Command.execute('git add rakefile.rb')
        # cmd=Command.execute('git commit -m"added rakefile.rb"')
        # cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
        # cmd=Command.execute('git push')
        # cmd=Command.execute('git push --tags')
      end
    end

    unless dir.include?(" ")
      # ADD
      # dev.execute("add \"#{dir}/HelloRake.git\" local/HelloRake 1s")

      # WORK
      # expect(dev.execute('work HelloRake')).not_to eq 0
      # dev.env.output=''

      # MAKE
      # expect(dev.execute('make HelloRake')).not_to eq 0
    end

    Dir.remove dir
  end
end
