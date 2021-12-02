# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('../apps/svn')
require_relative('dir')
require_relative('environment')
require_relative('string')

class Project < Hash
  attr_accessor :filename, :env

  def initialize(value = '', fullname = '')
    @filename = ''
    @env = Environment.new
    self[:url] = Project.get_url
    self[:fullname] = Project.get_fullname_from_url self[:url] if self[:url].length.positive?
    self[:timeout] = 60 * 5
    if value.is_a?(String)
      self[:url] = value if value.is_a?(String) && value.length.positive?
      self[:fullname] = Project.get_fullname_from_url self[:url]
    elsif value.is_a?(Hash)
      value.each { |k, v| self[k.to_sym] = v }
    elsif self[:url].length.positive?
      self[:fullname] = Project.get_fullname_from_url self[:url]
    end
    self[:fullname] = fullname if fullname.length.positive?
  end

  def set_timeout(value)
    self[:timeout] = value if value.is_a? Numeric
    self[:timeout] = value.gsub('m', '').strip.to_f * 60 if value.include?('m')
    self[:timeout] = value.gsub('s', '').strip.to_f * 60 if value.include?('s')
  end

  def self.get_url(directory = Rake.application.original_dir)
    url = ''
    Dir.chdir(directory) do
      url = `git config --get remote.origin.url`.strip if File.exist?('.git')
      url = Svn.url.strip if File.exist?('.svn')
    end
    url
  end

  def self.get_fullname(directory)
    directory.gsub(@env.wrk_dir, '')
  end

  def self.get_fullname_from_url(url)
    url.gsub('http://', '').gsub('https://', '').gsub('.com/', '/').gsub('.git', '')
  end

  def url
    self[:url]
  end

  def fullname
    self[:fullname]
  end

  def name
    parts = fullname.split('/')
    parts[parts.length - 1]
  end

  def wrk_dir
    "#{@env.wrk_dir}/#{fullname}"
  end

  def make_dir(tag = '')
    "#{@env.make_dir}/#{fullname}" if tag.length.zero?
    "#{@env.make_dir}/#{fullname}-#{tag}"
  end

  def pull
    if File.exist?(wrk_dir) && File.exist?("#{wrk_dir}/.git")
      Dir.chdir(wrk_dir) do
        puts "git pull (#{wrk_dir})"
        puts `git pull`
      end
    end
  end

  def clone
    if !File.exist?(wrk_dir) && self[:url].include?('.git')
      cmd = Command.new({ input: "git clone #{self[:url]} #{wrk_dir}", quiet: true,
                          ignore_failure: true })
      cmd.execute
      @env.out cmd.summary
    end
  end

  def checkout
    if !File.exist?(wrk_dir) && self[:url].include?('svn')
      cmd = Command.new({ input: "svn checkout #{url} #{wrk_dir}", quiet: true,
                          ignore_failure: true })
      cmd.execute
      @env.out cmd.summary
    end
  end

  def rake
    unless File.exist?(wrk_dir)
      clone
      checkout
    end
    if File.exist?(wrk_dir)
      Dir.chdir(wrk_dir) do
        rake = Command.new({ input: 'rake', timeout: 300, ignore_failure: true })
        rake.execute
        @env.out rake.summary
      end
    end
  end

  def latest_tag(update = false)
    makedir = "#{@env.make_dir}/#{fullname}"
    FileUtils.mkdir_p(File.dirname(makedir)) unless File.exist?(File.dirname(makedir))
    if File.exist?(makedir)
      Dir.chdir(makedir) do
        Command.exit_code('git pull') if update
      end
    elsif update
      clone = Command.new("git clone #{url} #{makedir}")
      clone[:quiet] = true
      clone[:ignore_failure] = true
      clone.execute
    end
    if File.exist?(makedir)
      Dir.chdir(makedir) do
        return Git.latest_tag
      rescue StandardError
      end
    end
    ''
  end

  def log_filenames(tags = nil)
    tags = [] if tags.nil?
    filenames = []
    Dir.chdir(@env.log_dir) do
      dotname = fullname.gsub('/', '.')
      Dir.glob("#{dotname}*.json").each do |f|
        if tags.length.zero?
          filenames << "#{@env.log_dir}/#{f}"
        else
          has_tags = true
          tags.each  do |tag|
            has_tags = false unless f.include? tag
          end
          filenames << "#{@env.log_dir}/#{f}" if has_tags
        end
      end
    end
    filenames
  end

  def command_history(tags = nil)
    commands = []
    log_filenames(tags).each do |logfile|
      cmd = Command.new(JSON.parse(IO.read(logfile)))
      commands << cmd
    rescue StandardError
    end
    commands
  end

  def work_up_to_date?
    if wrk_dir == Rake.application.original_dir
      logfile = get_logfile ['up2date']
      if File.exist? logfile
        last_work_time = File.mtime(logfile)
        last_file_changed = Dir.get_latest_mtime Rake.application.original_dir
        if last_work_time > last_file_changed
          CLEAN.include logfile
          return true
        else
          puts "   deleting #{logfile}" if @env.debug?
          File.delete(logfile)
        end
      elsif @env.debug?
        puts "logfile #{logfile} does NOT exist."
      end
    elsif @env.debug?
      puts 'wrk_dir does not match Rake.application.original_dir'
    end
    false
  end

  def mark_work_up_to_date
    if wrk_dir == Rake.application.original_dir
      logfile = get_logfile ['up2date']
      puts "   writing #{logfile}" if Environment.default.debug?
      File.open(logfile, 'w') { |f| f.write(' ') }
    elsif @env.debug?
      puts 'wrk_dir does not match Rake.application.original_dir'
    end
  end

  def get_logfile(tags)
    tagstring = ''
    tagstring = tags if tags.is_a?(String)
    tagstring = tags.join('.') if tags.is_a?(Array)
    name = "#{fullname}.#{tagstring}.json".gsub('/', '.')
    "#{@env.log_dir}/#{name}"
  end

  def list
    history = command_history
    if history.length.zero?
      @env.out "?      #{fullname}"
    else
      status = 0
      history.each do |c|
        status = c.exit_code if c.exit_code != 0
      end
      if status.zero?
        @env.out "       #{fullname}"
      elsif @env.colorize?
        require 'ansi/code'
        @env.out ANSI.red + ANSI.bright + "X      #{fullname}" + ANSI.reset
      else
        @env.out "X      #{fullname}"
      end
    end
  end

  def out_brackets(message)
    if @env.colorize?
      require 'ansi/code'
      @env.out "[#{ANSI.blue}#{ANSI.bright}#{message}#{ANSI.reset}]"
    else
      @env.out "[#{message}]"
    end
  end

  def out_cyan(message)
    if @env.colorize?
      require 'ansi/code'
      @env.out ANSI.cyan + ANSI.bright + message + ANSI.reset
    else
      @env.out message.to_s
    end
  end

  def out_property(name, value)
    if @env.colorize?
      require 'ansi/code'
      @env.out "#{name}: " + ANSI.white + ANSI.bold + value.to_s.strip + ANSI.reset
    else
      @env.out "#{name}: #{value}"
    end
  end

  def info
    infoCmd = Command.new({ input: 'info', exit_code: 0 })
    # out_cyan '========================================================='
    # out_cyan fullname
    out_property 'fullname'.fix(15), fullname
    out_property 'url'.fix(15), url
    wrk_history = command_history ['work']
    out_property 'work status'.fix(15), '?' if wrk_history.length.zero?
    out_property 'work status'.fix(15), wrk_history[0].summary if wrk_history.length.positive?
    @env.out wrk_history[0].info if wrk_history.length.positive?
    make_history = command_history ['make', latest_tag]
    out_property 'make status'.fix(15), '?' if make_history.length.zero?
    out_property 'make status'.fix(15), make_history[0].summary if make_history.length.positive?
    @env.out make_history[0].info if make_history.length.positive?
    infoCmd
  end

  def clobber
    clobberCmd = Command.new('clobber')
    clobberCmd[:exit_code] = 0
    if File.exist?(wrk_dir)
      Dir.remove wrk_dir, true
      @env.out "removed #{wrk_dir}"
    end
    if File.exist?(make_dir)
      Dir.remove make_dir, true
      @env.out "removed #{make_dir}"
    end
    clobberCmd
  end

  def work
    clone
    checkout
    logfile = get_logfile ['work']
    if File.exist?(wrk_dir)
      rake_default = Command.new({ input: 'rake default', quiet: true, ignore_failure: true })
      if last_work_mtime.nil? || last_work_mtime < Dir.get_latest_mtime(wrk_dir)
        Dir.chdir(wrk_dir) do
          @env.out fullname

          if !File.exist? 'rakefile.rb'
            rake_default[:exit_code] = 1
            rake_default[:error] = 'rakefile.rb not found.'
            rake_default[:start_time] = Time.now
            rake_default[:end_time] = Time.now
          else
            # rake_default[:timeout] = self[:timeout]
            rake_default.execute
          end
          rake_default.save logfile
          update_status
          @env.out rake_default.summary true
          return rake_default
        end
      elsif File.exist?(logfile)
        rake_default.open logfile
        @env.out rake_default.summary true if rake_default[:exit_code] != 0 || @env.show_success?
      end
      rake_default
    end
  end

  def make(tag = '')
    tag = latest_tag true if tag.length.zero?
    # return if tag.length==0
    raise 'no tag specified' if tag.length.zero?

    rake_default = Command.new({ input: 'rake default', quiet: true, ignore_failure: true })
    logfile = get_logfile ['make', tag]
    if File.exist?(logfile)
      rake_default.open logfile
      @env.out rake_default.summary true if (rake_default[:exit_code] != 0) || @env.show_success?
    else
      makedir = make_dir tag
      FileUtils.mkdir_p(File.dirname(makedir)) unless File.exist? File.dirname(makedir)
      if self[:url].include?('.git') && !File.exist?(makedir)
        clone = Command.new({ input: "git clone #{self[:url]} #{makedir}", quiet: true })
        clone.execute
      end
      if File.exist?(makedir)
        Dir.chdir(makedir) do
          checkout = Command.new({ input: "git checkout #{tag}", quiet: true })
          checkout.execute
          FileUtils.rm_r '.git'
          if !File.exist? 'rakefile.rb'
            rake_default[:exit_code] = 1
            rake_default[:error] = 'rakefile.rb not found.'
            rake_default[:start_time] = Time.now
            rake_default[:end_time] = Time.now
          else
            # rake_default[:timeout] = self[:timeout]
            rake_default.execute
          end
          rake_default.save logfile
          update_status
          @env.out rake_default.summary true
          rake_default
        end
      elsif @env.debug?
        puts "Project make make_dir #{makedir} does not exist."
      end

      begin
        FileUtils.rm_r makedir
      rescue StandardError
      end
    end
    rake_default
  end

  def last_work_mtime
    logfile = get_logfile ['work']
    return File.mtime(logfile) if File.exist? logfile

    nil
  end

  def update_status
    status_logfile = "#{@env.root_dir}/log/#{fullname}/#{@env.user}@#{@env.machine}.status.json"
    status = Hash.new({ 'status' => '?' })
    wrk_logfile = "#{@env.root_dir}/log/#{fullname}/#{@env.user}@#{@env.machine}.json"
    if File.exist?(wrk_logfile)
      rake_default = Command.new(JSON.parse(IO.read(wrk_logfile)))
      status[:work_logfile] = wrk_logfile
      status['status'] = '0'
      status['status'] = 'X' if rake_default[:exit_code] != 0
    end
    make_logfile = "#{@env.root_dir}/log/#{fullname}/#{latest_tag}/#{@env.user}@#{@env.machine}.json"
    if File.exist?(make_logfile)
      rake_default = Command.new(JSON.parse(IO.read(make_logfile)))
      status[:make_logfile] = make_logfile
      status['status'] = '0'
      status['status'] = 'X' if rake_default[:exit_code] != 0
    else
      status['status'] = '?'
    end
    FileUtils.mkdir_p(File.dirname(status_logfile)) unless File.exist?(File.dirname(status_logfile))
    File.open(status_logfile, 'w') { |f| f.write(status.to_json) }
  end

  def status
    status_logfile = "#{@env.root_dir}/log/#{fullname}/#{@env.user}@#{@env.machine}.status.json"
    update_status unless File.exist? status_logfile
    if File.exist?(status_logfile)
      statusHash = JSON.parse(IO.read(status_logfile))
      return statusHash['status'] if statusHash.key?('status')
    end
    '?'
  end

  def report; end

  def update
    clone
    checkout
    if File.exist?(wrk_dir)
      Dir.chdir(wrk_dir) do
        if File.exist?('.git')
          pull = Command.execute(Command.new({ input: 'git pull', quiet: true, ignore_failure: true }))
          @env.out pull.summary true
          return pull
        end
        if File.exist?('.svn')
          updateCmd = Command.execute(Command.new({ input: 'svn update', quiet: true,
                                                    ignore_failure: true }))
          @env.out updateCmd.summary true
          return updateCmd
        end
      end
    end
    Command.new({ exit_code: 1 })
  end

  def tags
    tags = []
    unless File.exist? wrk_dir
      clone = Command.new({ input: "git clone #{self[:url]} #{wrk_dir}", quiet: true })
      clone.execute
    end
    Dir.chdir(wrk_dir) do
      Command.output('git tag').split('\n').each do |line|
        tag = line.strip
        tags << tag if tag.length.negative?
      end
    end
    tags
  end
end
