# frozen_string_literal: true

puts DELIMITER if defined?(DEBUG)
puts __FILE__ if defined?(DEBUG)

require "json"
require "rake"
require_relative("environment")
require_relative("project")
require_relative("../apps/git")
require_relative("../apps/svn")

class Projects < Hash
  attr_accessor :env

  def initialize(env = nil)
    @env = env if env.is_a?(Environment)
    @env = Environment.new if @env.nil?
    open
  end

  def filename
    "#{@env.root_dir}/data/Projects.json"
  end

  def current
    fullname = Rake.application.original_dir.gsub("#{Environment.default.wrk_dir}/", "")
    if key? fullname
      self[fullname]
    else
      project = nil
      begin
        project = Project.new(Project.get_url, fullname)
      rescue StandardError
        project = nil
      end
      project
    end
  end

  def save
    Dir.make File.dirname(filename) unless File.exist? File.dirname(filename)
    File.open(filename, "w") { |f| f.write(JSON.pretty_generate(self)) }
  end

  def open
    if File.exist? filename
      JSON.parse(IO.read(filename)).each do |k, v|
        self[k] = if v.is_a?(Project)
            v
          else
            Project.new(v)
          end
      end
      # update_state
    end
  end

  def get_projects(value = "")
    puts "get_projects #{value}" if @env.debug?
    puts "get_project total project count #{length}" if @env.debug?
    projects = []
    filter = ""
    filter = value.to_s if !value.nil? && value.is_a?(String)
    filter = value[0].to_s if !value.nil? && value.is_a?(Array) && !value[0].to_s.include?("=")

    puts "get_project filter '#{filter}'" if @env.debug?
    each do |k, v|
      puts " checking project #{k}" if @env.debug?
      puts " v.class #{v.class}" if @env.debug?
      if (filter.length.zero? || k.include?(filter)) && v.is_a?(Project)
        projects << v
        v.env = @env
      end
    end
    projects
  end

  def add(args)
    url = args[0]
    project = Project.new(url)
    project[:fullname] = args[1] if args.length > 1
    project.set_timeout args[2] if args.length > 2
    if !key?(project[:fullname]) && project[:fullname].length.positive?
      @env.out "adding #{project.fullname}\n"
      self[project.fullname] = project
      save
    end
  end

  def remove(args)
    projects = get_projects args
    puts "removing #{projects.length} projects..." if @env.debug?
    remove_keys = []
    projects.each do |project|
      project.clobber
      remove_keys << project.fullname
    end
    remove_keys.each { |key| delete(key) }
    save
    0
  end

  def help(args); end

  def work(args)
    projects = get_projects args
    puts "working #{projects.length} projects..." if @env.debug?
    exit_code = 0
    projects.each do |project|
      result = project.work
      exit_code = result.exit_code if result.exit_code != 0
    rescue StandardError => e
      puts "error raised during work #{project.fullname}"
      puts "--------------------------------------------"
      puts e
      puts "--------------------------------------------"
    end
    exit_code
  end

  def info(args)
    projects = get_projects args
    puts "collecting info for #{projects.length} projects..." if @env.debug?
    exit_code = 0
    projects.each do |project|
      result = project.info
      exit_code = result.exit_code if result.exit_code != 0
    rescue StandardError => e
      puts "error raised during work #{project.fullname}"
      puts "--------------------------------------------"
      puts e
      puts "--------------------------------------------"
    end
    exit_code
  end

  def list(args)
    projects = get_projects args
    puts "listing #{projects.length} projects..." if @env.debug?
    projects.each(&:list)
    0
  end

  def make(args)
    projects = get_projects args
    puts "making #{projects.length} projects..." if @env.debug?
    exit_code = 0
    projects.each do |project|
      result = project.make
      exit_code = result.exit_code if result.exit_code != 0
    rescue StandardError => e
      puts "error raised during make #{project.fullname}"
      puts "--------------------------------------------"
      puts e
      puts "--------------------------------------------"
    end
    exit_code
  end

  def clobber(args)
    projects = get_projects args
    puts "clobbering #{projects.length} projects..." if @env.debug?
    projects.each do |project|
      project.clobber
      # Dir.remove_empty @env.wrk_dir
    rescue StandardError => e
      puts "error raised during clobber #{project.fullname}"
      puts "--------------------------------------------"
      puts e
      puts "--------------------------------------------"
    end
  end

  def update(args)
    projects = get_projects args
    puts "updating #{projects.length} projects..." if @env.debug?
    projects.each do |project|
      puts "updating #{project.fullname}" if @env.debug?
      result = project.update
      exit_code = result.exit_code if result.exit_code != 0
    rescue StandardError => e
      puts "error raised during update #{project.fullname}"
      puts "--------------------------------------------"
      puts e
      puts "--------------------------------------------"
    end
  end

  def self.user_projects_filename
    FileUtils.mkdir_p("#{Environment.dev_root}/data") unless File.exist?("#{Environment.dev_root}/data")
    "#{Environment.dev_root}/data/PROJECTS.json"
  end

  def self.current
    project = nil
    url = Git.remote_origin
    url = Svn.url if url.length.zero?
    if Rake.application.original_dir.include?("/wrk/") &&
       url.length.positive?
      project = Project.new(url)
      fullname = Rake.application.original_dir.gsub("#{Environment.dev_root}/wrk/", "")
      project[:fullname] = name if name.length.positive? && !name.include?(Environment.dev_root)
      if defined?(PROJECTS)
        PROJECTS[name] = project unless PROJECTS.key?(name)
        project.each { |k, v| PROJECTS[name][k] = v }
        PROJECTS.save
      else
        project[:fullname] = name
      end
    end
    project
  end

  def pull
    each { |_k, v| v.pull if v.respond_to?("pull".to_sym) }
  end

  def rake
    each { |_k, v| v.rake if v.respond_to?("rake".to_sym) }
  end

  def import(pattern = "")
    wrk = @env.wrk_dir
    if File.exist?(wrk)
      Dir.chdir(wrk) do
        puts "scanning #{wrk} for imports..."
        Dir.glob("**/rakefile.rb").each do |rakefile|
          rakedir = File.dirname(rakefile)
          url = Project.get_url rakedir
          project = Project.new(Project.get_url(rakedir))
          project[:fullname] = rakedir.gsub(@env.wrk_dir, "") if project.fullname.include?(":")
          if (pattern.length.zero? || project.fullname.include?(pattern)) && (project.fullname.length.positive? && !key?(project.fullname))
            puts "importing #{project.fullname}"
            self[project.fullname] = project
          end
        end
      end
      save
    end
  end
end
