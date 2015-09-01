puts __FILE__ if defined?(DEBUG)

require_relative('string.rb')

class Environment < Hash
  attr_accessor :output
  @@default=nil
  def self.default
    @@default=Environment.new if @@default.nil?
    @@default
  end

  def initialize env=nil
    @output=''
    @env=Hash.new
    @env_aliases={'HOME' => ['USERPROFILE'],
                  'DEV_ROOT' => ['DEV_HOME','HOME','USERPROFILE'],
                  'USERNAME' => ['USER','USR']
    }
    env.each{|k,v| @env[k.to_s]=v} if !env.nil?
    @@default=self if @@default.nil?
  end

  #####Begin LEGACY support
  def self.dev_root
    default.root_dir
  end

  #####End LEGACY support
  def root_dir
    get_env('DEV_ROOT').gsub('\\','/')
  end
 
  def home_dir
    get_env('HOME').gsub('\\','/')
  end

  def log_dir
    dir="#{root_dir}/log/#{user}@#{machine}"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def make_dir
    dir="#{root_dir}/make"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def publish_dir
    dir="#{root_dir}/publish"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def wrk_dir
    dir="#{root_dir}/wrk"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def machine
    return ENV['COMPUTERNAME'] if !ENV['COMPUTERNAME'].nil? 
    machine = `hostname`
    machine = machine.split('.')[0] if machine.include?('.')
    return machine.strip
  end

  def user
    get_env('USERNAME')
    #return ENV['USER'] if !ENV['USER'].nil?  #on Unix
    #ENV['USERNAME']
  end

  def get_env key
    if(!@env.nil? && @env.has_key?(key))
      return @env[key] 
      end
    value = ENV[key]
    if(value.nil?)
      if(@env_aliases.has_key?(key))
        @env_aliases[key].each{|akey|
          value=get_env(akey) if value.nil?
        }
      end
    end
    value
  end

  def set_env key,value
    @env[key]=value
  end

  def debug?
    return true if get_env('DEBUG')=='true'
    false
  end

  def colorize?
    colorize=true
    if windows?
      if(`gem list win32console`.include?('win32console'))
        require 'ansi/code'
      else
        colorize=false
      end
    end
    colorize
  end

  def out message
      puts message if !get_env('SUPPRESS_CONSOLE_OUTPUT')
      @output=@output+message+'\n'
  end

  def show_success?
    true
  end

  def windows?
    Gem.win_platform?
  end

  #@@debug=true if defined?(DEBUG)
  #@@debug=false if !defined?(DEBUG)
  #@@development_root=nil

  #def initialize
    #self[:home]=Environment.home
    #self[:machine]=Environment.machine
    #self[:user]=Environment.user
  #end

  #def self.set_development_root value
  #  @@development_root=value
  #  if(!value.nil?)
  #    FileUtils.mkdir_p value if(!File.exists?(value))
  #    ['bin','data','log','make','publish','test'].each{|dir|
  #      #FileUtils.mkdir_p("#{value}/#{dir}") if !File.exists? "#{value}/#{dir}"
  #    }
  #  end
  #end

  #def self.debug
  #  @@debug
  #end

  #def self.home 
  #  ["USERPROFILE","HOME"].each {|v|
  #    return ENV[v].gsub('\\','/') unless ENV[v].nil?
  #  }
  #  dir="~"
  #  dir=ENV["HOME"] unless ENV["HOME"].nil?
  #  dir=ENV["USERPROFILE"].gsub('\\','/') unless ENV["USERPROFILE"].nil?
  #  return dir
  #end

  #def self.configuration
  #  config="#{Environment.home}/dev.config.rb"
  #  if(!File.exists?(config))
  #    text=IO.read("#{File.dirname(__FILE__)}/../dev.config.rb")
  #    File.open(config,'w'){|f|f.write(text)}
  #  end
  #  config
  #end

  #def self.machine
  #   if !ENV['COMPUTERNAME'].nil? 
	#   return ENV['COMPUTERNAME']
	# end

  #   machine = `hostname`
  #   machine = machine.split('.')[0] if machine.include?('.')
	# return machine.strip
  #end

  def self.remove directory
    if(File.exists?(directory))
      begin
        FileUtils.rm_rf directory
        FileUtils.rm_r directory
      rescue
      end
    end
  end

  #def self.user
 # 	return ENV['USER'] if !ENV['USER'].nil?  #on Unix
 #   ENV['USERNAME']
  #end

  #def self.dev_root
  #  if(!@@development_root.nil?)
  #    return @@development_root
  #  end
  #  ["DEV_HOME","DEV_ROOT"].each {|v|
  #    return ENV[v].gsub('\\','/') unless ENV[v].nil?
  #  }
  #  dir=home
  # return dir
  #end

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

  def self.get_latest_mtime directory
    mtime=Time.new(1980)
    Dir.chdir(directory)  do
      Dir.glob('**/*.*').each{|f|
        mtime=File.mtime(f) if mtime.nil? || File.mtime(f) > mtime
      }
    end
    mtime
  end
end