# frozen_string_literal: true

puts DELIMITER if defined?(DEBUG)
puts __FILE__ if defined?(DEBUG)

require_relative('string')

class Environment < Hash
  attr_accessor :output, :publish_dir

  @@default = nil
  def self.default
    @@default = Environment.new if @@default.nil?
    @@default
  end

  def initialize(env = nil)
    @output = ''

    @env = {}
    @env_aliases = { 'HOME' => ['USERPROFILE'],
                     'DEV_ROOT' => %w[DEV_HOME HOME USERPROFILE],
                     'USERNAME' => %w[USER USR] }
    env&.each { |k, v| @env[k.to_s] = v }
    @@default = self if @@default.nil?

    @publish_dir = "#{root_dir}/publish"
    FileUtils.mkdir_p @publish_dir unless File.exist? @publish_dir
  end

  # ####Begin LEGACY support
  def self.dev_root
    default.root_dir
  end
  # ####End LEGACY support

  def admin?
    rights = `whoami /priv`
    rights.include?('SeCreateGlobalPrivilege')
  end

  def root_dir
    get_env('DEV_ROOT').gsub('\\', '/')
  end

  def home_dir
    get_env('HOME').gsub('\\', '/')
  end

  def log_dir
    dir = "#{root_dir}/log/#{user}@#{machine}"
    FileUtils.mkdir_p dir unless File.exist? dir
    dir
  end

  def dropbox_dir
    dropbox_info = "#{ENV['LOCALAPPDATA']}/Dropbox/info.json"
    if File.exist?(dropbox_info)
      info = JSON.parse(IO.read(dropbox_info))
      return info['personal']['path'] if info.key?('personal') && info['personal'].key?('path')
    end
    ''
  end

  def tmp_dir
    dir = "#{root_dir}/tmp"
    FileUtils.mkdir_p dir unless File.exist? dir
    dir
  end

  def make_dir
    dir = "#{root_dir}/make"
    FileUtils.mkdir_p dir unless File.exist? dir
    dir
  end

  def wrk_dir
    dir = "#{root_dir}/work"
    FileUtils.mkdir_p dir unless File.exist? dir
    dir
  end

  def machine
    return ENV['COMPUTERNAME'] unless ENV['COMPUTERNAME'].nil?

    machine = `hostname`
    machine = machine.split('.')[0] if machine.include?('.')
    machine.strip
  end

  def user
    get_env('USERNAME')
  end

  def get_env(key)
    return @env[key] if !@env.nil? && @env.key?(key)

    value = ENV[key]
    if value.nil? && @env_aliases.key?(key)
      @env_aliases[key].each  do |akey|
        value = get_env(akey) if value.nil?
      end
    end
    value
  end

  def set_env(key, value)
    @env[key] = value
  end

  def debug?
    return true if defined?(DEBUG)

    false
  end

  def colorize?
    colorize = true
    if Environment.windows?
      if `gem list win32console`.include?('win32console')
        require 'ansi/code'
      else
        colorize = false
      end
    end
    colorize = false if Environment.mac?
    colorize
  end

  def working?
    return true if Rake.application.original_dir.include? wrk_dir

    false
  end

  def has_work?
    true
  end

  def out(message)
    puts message unless get_env('SUPPRESS_CONSOLE_OUTPUT')
    @output = "#{@output}#{message}\\n"
  end

  def show_success?
    true
  end

  def self.OS
    if windows?
      'windows'
    elsif mac?
      'mac'
    elsif linux?
      'linux'
    else
      'unix'
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
    unix? and !mac?
  end

  def self.check
    puts 'checking commands...'
    missing_command = false
    ['ruby --version', 'svn --version --quiet', 'git --version', 'msbuild /version', 'nunit-console', 'nuget', 'candle',
     'light', 'gem --version'].each do |cmd|
      command = Command.new(cmd)
      command[:quiet] = true
      command[:ignore_failure] = true
      command.execute
      if (command[:exit_code]).zero?
        puts "#{cmd.split(' ')[0]} #{get_version(command[:output])}"
      else
        puts "#{cmd.split(' ')[0]} not found."
        missing_command = true
      end
    end
    if missing_command
      puts 'missing commands may be resolved by making sure that are installed and in PATH environment variable.'
    end
  end

  def self.get_version(text)
    text.match(/(\d+\.\d+\.[\d\w]+)/)
  end

  def info
    puts 'Environment'
    puts "  ruby version: #{`ruby --version`}"
    puts " ruby platform: #{RUBY_PLATFORM}"
    puts "      dev_root: #{root_dir}"
    puts "       machine: #{machine}"
    puts "          user: #{user}"
    puts "            os: #{Environment.OS}"
    # puts " configuration: #{self.configuration}"
    puts "         debug: #{debug?}"
    # puts "git user.email: #{Git.user_email}"
    puts ' '
    # puts "Path Commands"
    # ['svn --version --quiet','git --version','msbuild /version','nuget','candle','light','gem --version'].each{|cmd|
    #  command=Command.new(cmd)
    #  command[:quiet]=true
    #  command[:ignore_failure]=true
    #  command.execute
    #  if(command[:exit_code] == 0)
    #    puts "#{cmd.split(' ')[0].fix(14)} #{Environment.get_version(command[:output])}"
    #  else
    #    puts "#{cmd.split(' ')[0].fix(14)} not found."
    #      missing_command=true
    #  end
    # }
  end
end

puts '' if defined?(DEBUG)
puts Environment.default.info if defined?(DEBUG)
