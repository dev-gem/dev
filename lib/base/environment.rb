puts __FILE__ if defined?(DEBUG)

require_relative('string.rb')

class Environment < Hash
  attr_accessor :output,:publish_dir
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

    @publish_dir="#{root_dir}/publish"
    FileUtils.mkdir_p @publish_dir if !File.exists? @publish_dir
  end

  #####Begin LEGACY support
  def self.dev_root
    default.root_dir
  end
  #####End LEGACY support

  def admin?
    rights=%x[whoami /priv]
    return rights.include?('SeCreateGlobalPrivilege')
  end
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

  def dropbox_dir
    dropbox_info = "#{ENV['LOCALAPPDATA']}/Dropbox/info.json"
    if(File.exists?(dropbox_info))
      info = JSON.parse(IO.read(dropbox_info))
      if(info.has_key?('personal'))
        if(info['personal'].has_key?('path'))
          return info['personal']['path']
        end
      end
    end
    ""
  end

  def tmp_dir
    dir="#{root_dir}/tmp"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def make_dir
    dir="#{root_dir}/make"
    FileUtils.mkdir_p dir if !File.exists? dir
    dir
  end

  def wrk_dir
    dir="#{root_dir}/work"
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
    if Environment.windows?
      if(`gem list win32console`.include?('win32console'))
        require 'ansi/code'
      else
        colorize=false
      end
    end
    if Environment.mac?
      colorize=false
    end
    colorize
  end

  def working?
    return true if Rake.application.original_dir.include? wrk_dir
    false
  end

  def has_work?
    true
  end

  def out message
      puts message if !get_env('SUPPRESS_CONSOLE_OUTPUT')
      @output=@output+message+'\n'
  end

  def show_success?
    true
  end

  def self.OS
    if windows?
      return "windows"
    else
      if mac?
        return "mac"
      else
        if linux?
          return "linux"
        else
          return "unix"
        end
      end
    end
  end

  def self.windows?
    Gem.win_platform?
  end

  def self.mac?
   (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def self.unix?
    !windows?
  end

  def self.linux?
    unix? and not mac?
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

  def info 
    puts "Environment"
    puts "  ruby version: #{`ruby --version`}"
    puts " ruby platform: #{RUBY_PLATFORM}"
    puts "      dev_root: #{self.root_dir}"
    puts "       machine: #{self.machine}"
    puts "          user: #{self.user}"
    #puts " configuration: #{self.configuration}"
    puts "         debug: #{self.debug?}"
    puts "git user.email: #{Git.user_email}" 
    puts " "
    puts "Path Commands"
    ['svn --version --quiet','git --version','msbuild /version','nuget','candle','light','gem --version'].each{|cmd|
      command=Command.new(cmd)
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      if(command[:exit_code] == 0)
        puts "#{cmd.split(' ')[0].fix(14)} #{Environment.get_version(command[:output])}"
      else
        puts "#{cmd.split(' ')[0].fix(14)} not found."
          missing_command=true
      end
    }
  end
end