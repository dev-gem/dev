puts __FILE__ if defined?(DEBUG)

require_relative('string.rb')

class Environment < Hash

  @@debug=true if defined?(DEBUG)
  @@debug=false if !defined?(DEBUG)

  def initialize
    self[:home]=Environment.home
    self[:machine]=Environment.machine
    self[:user]=Environment.user
  end

  def self.debug
    @@debug
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

  def self.configuration
    config="#{Environment.home}/dev.config.rb"
    if(!File.exists?(config))
      text=IO.read("#{File.dirname(__FILE__)}/../dev.config.rb")
      File.open(config,'w'){|f|f.write(text)}
    end
    config
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
  	return ENV['USER'] if !ENV['USER'].nil?  #on Unix
    ENV['USERNAME']
  end

  def self.dev_root
    ["DEV_HOME","DEV_ROOT"].each {|v|
      return ENV[v].gsub('\\','/') unless ENV[v].nil?
    }
    dir=home
   return dir
  end

  def self.check
    puts 'checking commands...'
    missing_command=false
    ['ruby --version','svn --version --quiet','git --version','msbuild /version','nunit-console','nuget','candle','light','gem --version'].each{|cmd|
      command=Command.new(cmd)
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      if(command[:exit_code] == 0)
        puts "#{cmd.split(' ')[0]} #{get_version(command[:output])}"
      else
        puts "#{cmd.split(' ')[0]} not found."
          missing_command=true
      end
      
    }
    puts "missing commands may be resolved by making sure that are installed and in PATH environment variable." if missing_command
  end

  def self.get_version text
    text.match(/(\d+\.\d+\.[\d\w]+)/)
  end

  def self.info 
    puts "Environment"
    puts "  ruby version: #{`ruby --version`}"
    puts " ruby platform: #{RUBY_PLATFORM}"
    puts "      dev_root: #{Environment.dev_root}"
    puts "       machine: #{Environment.machine}"
    puts "          user: #{Environment.user}"
    puts " configuration: #{Environment.configuration}"
    puts "         debug: #{Environment.debug}"
    puts " "
    puts "Path Commands"
    ['svn --version --quiet','git --version','msbuild /version','nuget','candle','light','gem --version'].each{|cmd|
      command=Command.new(cmd)
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      if(command[:exit_code] == 0)
        puts "#{cmd.split(' ')[0].fix(14)} #{get_version(command[:output])}"
      else
        puts "#{cmd.split(' ')[0].fix(14)} not found."
          missing_command=true
      end
    }
  end
end