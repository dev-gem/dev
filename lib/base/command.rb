puts DELIMITER if defined?(DEBUG)
puts __FILE__ if defined?(DEBUG)

require 'time'
require 'open3'
require_relative('timeout.rb')
require_relative('timer.rb')
require_relative('array.rb')
require_relative('hash.rb')
require_relative('string.rb')
require_relative('environment.rb')
require_relative('dir.rb')
BUFFER_SIZE=1024 if(!defined?(BUFFER_SIZE))
            
# = Command
#
# execution of system commands
#
# = Keys
#
# - :input The input of the commands.
# - :timeout The timeout in seconds.
#          a value of zero is to infinite timeout.
#          defaults to zero
# - :directory The working directory for the command.
#             defaults to the current directory
# - :exit_code The exit code of the command
# - :output The output contains the stdout output of the command
# - :error The error contains stderr output of the command
# - :machine The name of the machine the command executed on
# - :user The user name
# - :start_time
# - :end_time
#
class Command < Hash
	def initialize command
    self[:input] = ''
		self[:timeout] = 0
		self[:directory] = ''
		self[:exit_code] = 0
		self[:output] = ''
		self[:error] = ''
		self[:machine] = ''
		self[:user] = ''
		self[:start_time] = nil
		self[:end_time] = nil

		if(command.kind_of?(String))
		  self[:input] = command
    end

    if(command.kind_of?(Hash))
      command.each{|k,v|self[k.to_sym]=v}
      self[:start_time]=Time.parse(self[:start_time]) if(self.has_key?(:start_time) && !self[:start_time].nil?)
      self[:end_time]=Time.parse(self[:end_time]) if(self.has_key?(:end_time) && !self[:end_time].nil?)
    end
	end

  def save filename
    File.open(filename,'w'){|f|f.write(to_json)}
  end

  def open filename=''
    @filename=filename if filename.length > 0
    self.clear
    JSON.parse(IO.read(@filename)).each{|k,v| self[k.to_sym]=v}
    self[:start_time]=Time.parse(self[:start_time]) if(self.has_key?(:start_time))
    self[:end_time]=Time.parse(self[:end_time]) if(self.has_key?(:end_time))
  end

  def quiet?
    (self.has_key?(:quiet) && self[:quiet])
  end

  def exit_code
    self[:exit_code]
  end

  def output
    self[:output]
  end
  def error
    self[:error]
  end
  def self.executes?(command)
    cmd = Command.new({ :input => command, :quiet => true,:ignore_failure => true})
    cmd.execute
    if(cmd[:exit_code] == 0)
      true
    else
      false
    end
  end

  # todo: add log of execution
	def execute value=nil

    puts "#{self[:input]}" if defined?(DEBUG)

    if(!value.nil? && value.is_a?(Hash))
      value.each{|k,v|self[k]=v}
    end

		pwd=Dir.pwd
		self[:directory] = pwd if(!self.has_key?(:directory) || self[:directory].length==0)

    if(self[:timeout] > 0)
      puts "#{self[:input]} (#{self[:directory]}) timeout #{self[:timeout].to_s}" if(!quiet?)
    else
		  puts "#{self[:input]} (#{self[:directory]})" if(!quiet?)
    end

		self[:machine] = Command.machine
		self[:user] = Command.user

		self[:start_time]=Time.now
		timer=Timer.new

    Dir.chdir(self[:directory]) do
  		if self[:input].include?('<%') && self[:input].include?('%>')
  		  ruby = self[:input].gsub("<%","").gsub("%>","")

  		  begin
  		    self[:output]=eval(ruby)
  		  rescue 
  		  	self[:exit_code]=1
  		  	self[:error]="unable to eval(#{ruby})"
  		  end

  		  self[:elapsed] = timer.elapsed_str
  		  self[:end_time] = Time.now
  		else
  			begin
          if(self[:timeout] <= 0)
            self[:output],self[:error],status= Open3.capture3(self[:input])
            self[:exit_code]=status.to_i
    			  self[:elapsed] = timer.elapsed_str
    			  self[:end_time] = Time.now
          else
            require_relative 'timeout.rb'
            result=run_with_timeout(self[:directory],self[:input], self[:timeout],2)
            self[:output]=result[0]
            self[:exit_code]=result[1]
            self[:elapsed] = timer.elapsed_str
            self[:end_time] = Time.now
            
            if(timer.elapsed >= self[:timeout])
              self[:exit_code]=1 
              self[:error] = self[:error] + "timed out"
            end
          end
  			rescue Exception => e
  			  self[:elapsed] = timer.elapsed_str
  			  self[:end_time] = Time.now
  			  self[:error] = "Exception: " + e.to_s
  			  self[:exit_code]=1
  		  end
  		end
    end
       

    if(self[:exit_code] != 0)
      if(!quiet?)
    	  puts "exit_code=#{self[:exit_code]}"
    	  puts self[:output]
    	  puts self[:error]
      end
    	if(!self.has_key?(:ignore_failure) || !self[:ignore_failure])
    		raise "#{self[:input]} failed\n#{self[:output]}\n#{self[:error]}" 
    	end
    end
    self 
	end

    def self.machine
      if !ENV['COMPUTERNAME'].nil? 
	   return ENV['COMPUTERNAME']
	  end

      machine = `hostname`
      machine = machine.split('.')[0] if machine.include?('.')
	  return machine.strip
    end

    def self.user
      ENV['USER'].nil? ? ENV['USERNAME'] : ENV['USER']
    end 

    def self.home 
      ["USERPROFILE","HOME"].each {|v|
        return ENV[v].gsub('\\','/') unless ENV[v].nil?
      }
      dir="~"
      dir=ENV["HOME"] unless ENV["HOME"].nil?
      dir=ENV["USERPROFILE"].gsub('\\','/') unless ENV["USERPROFILE"].nil?
      return dir
    end

    def self.dev_root
      ["DEV_HOME","DEV_ROOT"].each {|v|
        return ENV[v].gsub('\\','/') unless ENV[v].nil?
      }
      dir=home
     return dir
    end

    def self.execute command, working_directory=''
      cmd = Command.new({ :input => command, :quiet => true}) if command.kind_of?(String)
      cmd[:directory] = working_directory if command.kind_of?(String)
      cmd = command if command.kind_of?(Command)
      cmd = Command.new(command) if command.kind_of?(Hash)
      cmd.execute
      cmd[:exit_code]
      cmd
    end

    def self.exit_code command
    	cmd = Command.new(command)
    	cmd[:ignore_failure]=true
      cmd[:quiet]=true
    	cmd.execute
    	cmd[:exit_code]
    end

    def self.output command
    	cmd = Command.new(command)
    	cmd[:ignore_failure]=true
      cmd[:quiet]=true
    	cmd.execute
    	cmd[:output]
    end

    def self.error command
      cmd = Command.new(command)
      cmd[:ignore_failure]=true
      cmd[:quiet]=true
      cmd.execute
      cmd[:error]
    end

    def getFormattedTimeSpan timespan
      result=''
      seconds = timespan.round
      if(seconds > 99)
        minutes=(seconds/60).round
        result="#{minutes}m"
      else
        result="#{seconds}s" # 99s 
      end
      result.fix(3)
    end

    def summary include_directory=false
      duration=""
      duration=getFormattedTimeSpan(self[:end_time]-self[:start_time])
      if(Environment.default.colorize?)
        require 'ansi/code'
        cduration = ANSI.reset + duration
        #code=ANSI.green + '+ ' + ANSI.reset
        #code=ANSI.red   + '- ' + ANSI.reset if exit_code != 0
        cinput = ANSI.reset + self[:input] + ANSI.reset
        cinput = ANSI.red   + self[:input] + ANSI.reset if exit_code != 0
        cdirectory = ''
        cdirectory = "(#{self[:directory]})" if include_directory
        "  #{cduration} #{cinput} #{cdirectory}"
      else
        code=' '
        code='X' if exit_code != 0
        sdirectory = ''
        sdirectory = "(#{self[:directory]})" if include_directory
        "#{code} #{duration} #{self[:input]} #{sdirectory}"
      end
    end

    def format_property name,value
        if(Environment.default.colorize?)
            require 'ansi/code'
            return "#{name}: " + ANSI.yellow + ANSI.bright + value.to_s.strip + ANSI.reset
        else
            return "#{name}: #{value}"
        end
    end 

    def info 
      result=format_property('input'.fix(15),self[:input]) + "\n"
      result=result + format_property('directory'.fix(15),self[:directory])  + "\n"
      result=result + format_property('exit_code'.fix(15),self[:exit_code]) + "\n"
      result=result + format_property('duration'.fix(15),getFormattedTimeSpan(self[:end_time]-self[:start_time])) + "\n"
      output=['']
      output=self[:output].strip.split("\n") if !self[:output].nil?
      if(output.length <= 1)
        result=result + format_property('output'.fix(15),output[0]) + "\n" 
        #result=result + format_property('output'.fix(15),'') + "\n" if(output.length==0)
        #result=result + format_property('output'.fix(15),output) + "\n" if(output.length==1)
      else
        result=result + format_property('output'.fix(15),'') + "\n"
        output.each{|line|
          result=result + ' '.fix(16) + line + "\n"
        }
      end
      error=['']
      error=self[:error].strip.split("\n") if !self[:error].nil?
      if(error.length <= 1) 
        result=result + format_property('error'.fix(15),error[0]) + "\n"
        #result=result + format_property('error'.fix(15),'') + "\n" if(error.length==0)
        #result=result + format_property('error'.fix(15),error) + "\n" if(error.length==1)
      else
        result=result + format_property('error'.fix(15),'') + "\n"
        error.each{|line|
          result=result + ' '.fix(16) + line + "\n"
        }
      end
    end

    def to_html
      if self[:exit_code] == 0
      [
      	'<div><table><tr><td width="20"></td><td><pre>',
      	self[:input],
      	'</pre></td></tr></table></div>'
      ].join
      else
      [
      	'<div><table><tr><td width="20"></td><td><pre>',
      	self[:input],
        '</pre><table><tr><td width="20"></td><td><table>',
        map { |k, v| ["<tr><td><strong>#{k}</strong></td>", v.respond_to?(:to_html) ? v.to_html : "<td><span><pre>#{v}</pre></span></td></tr>"] },
        '</table>',
        '</td></tr></table></td></tr></table></div>'
      ].join
      end
    end
end