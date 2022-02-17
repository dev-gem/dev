# frozen_string_literal: true

require_relative("environment")

class Array
  attr_accessor :env

  def initialize(env = nil)
    @env = env
    @env = Environment.new if @env.nil?
    @env = Environmnet.new unless @env.is_a?(Environment)
  end

  def execute(value = nil)
    @env = Environment.new if @env.nil?
    i = 0
    # puts "Array.execute length=#{self.length}" if defined?(DEBUG)
    while i < length

      # puts self[i].to_s if defined?(DEBUG)
      # puts "Array[#{i.to_s}]'=nil" if @env.debug? && self[i].nil?
      # puts "Array[#{i.to_s}].class=#{self[i].class.to_s}" if @env.debug? && !self[i].nil?
      # puts "Array[#{i.to_s}].to_s=#{self[i].to_s}" if @env.debug? && !self[i].nil?
      self[i] = Command.new({ input: self[i], quiet: true }) if self[i].is_a?(String)
      self[i] = Command.new(self[i]) if self[i].is_a?(Hash) && !self[i].is_a?(Command)

      value.each { |k, v| self[i][k] = v } if !value.nil? && value.is_a?(Hash)

      if self[i].is_a?(Command)
        self[i].execute
        @env.out self[i].summary
      end

      i += 1
    end
  end

  def add(command)
    self << command unless has_command? command
  end

  def log_debug_info(title)
    if defined?(DEBUG) && length.positive?
      puts
      puts title
      each { |c| puts "  #{c[:input]}" }
      # pp self
      puts
    end
  end

  def has_command?(command)
    return true if command.is_a?(String) && !include?(command)

    if command.is_a?(Command)
      each do |c|
        if c.is_a?(String)
          return true if command[:input] == c
        elsif c[:input] == command[:input]
          return true
        end
      end
    end
    false
  end

  def add_quiet(command)
    add Command.new({ input: command, quiet: true })
  end

  def add_passive(command)
    add Command.new({ input: command, quiet: true, ignore_failure: true })
  end

  def to_html
    html = []
    html << "<div>"
    each do |e|
      html << e.to_html if e.respond_to?(:to_html)
    end
    html << "</div>"
    html.join
  end
end
