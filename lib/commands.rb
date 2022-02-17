# frozen_string_literal: true

if defined?(DEBUG)
  puts DELIMITER
  puts __FILE__
end

require_relative("apps")

require "json"
require "rake/clean"
require "pp"

Dir.glob("#{File.dirname(__FILE__)}/tasks/*.rb").sort.each do |rb|
  require(rb) unless rb.include?("default")
end

class Commands < Hash
  attr_accessor :env

  def initialize(env = nil, directory = Rake.application.original_dir)
    @env = env
    @env = Environment.new if @env.nil?
    Dir.chdir(directory) do
      self[:pull] = Pull.new
      self[:update] = Update.new
      self[:setup] = Setup.new
      self[:build] = Build.new
      self[:test] = Test.new
      self[:analyze] = Analyze.new
      self[:doc] = Doc.new
      self[:package] = Package.new
      self[:publish] = Publish.new
      self[:add] = Add.new
      self[:commit] = Commit.new
      self[:push] = Push.new
    end
  end

  def info
    puts "Commands"
    each do |k, v|
      v.update if v.respond_to? "update"
      next unless v.length.positive?

      puts " #{k}"
      v.each do |c|
        puts "  #{c[:input]}" unless c.is_a?(Hash)
      end
    end
  end
end

COMMANDS = Commands.new
MSBUILD = MSBuild.new
