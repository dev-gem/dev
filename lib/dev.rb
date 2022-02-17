# frozen_string_literal: true

DELIMITER = "==================================================================================="
puts DELIMITER if defined?(DEBUG)
puts __FILE__ if defined?(DEBUG)

require_relative("base")
require_relative("base/string")
require_relative("base/environment")
require_relative("base/giturl")
require_relative("base/projects")
require_relative("commands")

class Dev
  attr_accessor :env, :projects, :commands

  def initialize(env = nil)
    @env = Environment.new(env) if !env.nil? && env.is_a?(Hash)
    @env = Environment.new if @env.nil?
    @projects = Projects.new(@env)
    @commands = Commands.new(@env)
    @output = ""
  end

  def execute(args)
    args = args.split(" ") if args.is_a?(String)

    # parse arguments that are of the form KEY=VALUE
    args.each do |arg|
      next unless arg.include?("=")

      words = arg.split("=")
      ENV[words[0]] = words[1] if words.length == 2
    end

    if args.length.zero?
      usage
    else
      subcommand = args[0] if args.length.positive?
      subargs = []
      subargs = args[1, args.length - 1] if args.length > 1

      return projects.add(subargs) if subcommand == "add"
      return projects.clobber(subargs) if subcommand == "clobber"
      return projects.import(subargs) if subcommand == "import"
      return projects.list(subargs) if subcommand == "list"
      return projects.make(subargs) if subcommand == "make"
      return projects.info(subargs) if subcommand == "info"
      return projects.remove(subargs) if subcommand == "remove"
      return projects.work(subargs) if subcommand == "work"
      return projects.update(subargs) if subcommand == "update"

      @env.out "unknown command: '#{subcommand}'"
      1
    end
  end

  def usage
    return 0
    @env.out "usage: dev <subcommand> [options]"
    @env.out ""
    @env.out "available subcommands"
    @env.out " help"
    @env.out " list"
    @env.out " make"
    @env.out " info"
    @env.out " work"
    @env.out ""
    @env.out "Type 'dev help <subcommand>' for help on a specific subcommand.'"
    0
  end
end

require_relative("base")
require_relative("tasks")
require_relative("commands")

puts "defining DEV" if Environment.default.debug?
DEV = Dev.new
require_relative("tasks/default")
