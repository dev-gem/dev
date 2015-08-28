puts __FILE__ if defined?(DEBUG)

require 'time'
require 'open3'
require_relative('timeout.rb')
require_relative('timer.rb')
require_relative('array.rb')
require_relative('hash.rb')
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

	def execute value=nil

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
            self[:error]=result[1]
            self[:exit_code]=result[2]

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

    #def self.execute_quiet command
    #  cmd=Command.new({ :input => command, :quiet => true, :ignore_failure => true})
    #  cmd.execute
    #  cmd
    #end

    def self.execute command
      cmd = Command.new({ :input => command, :quiet => true}) if command.kind_of?(String)
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
      seconds = timespan.round
      seconds.to_s + " sec"
    end

    def summary
      duration=""
      duration=getFormattedTimeSpan(self[:end_time]-self[:start_time])
      if(Environment.default.colorize?)
        code=ANSI.green + '+ ' + ANSI.reset
        code=ANSI.red   + '- ' + ANSI.reset if exit_code != 0
        cinput = ANSI.yellow + self[:input] + ANSI.reset
        cinput = ANSI.red + self[:input] + ANSI.reset
        cdirectory = self[:directory]
        "#{code} #{cinput} (#{cdirectory}) [#{duration}]"
      else
        code='  '
        code='- ' if exit_code != 0
        "#{code} #{self[:input]} (#{self[:directory]}) [#{duration}]"
      end
      #status="OK   "
      #status="Error" if(!self.has_key?(:exit_code) || self[:exit_code] != 0)
      #{}"#{status} '#{self[:input]}' (#{self[:directory]}) #{self[:exit_code].to_s} [#{duration}]"
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