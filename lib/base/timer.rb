# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

class Timer
  attr_accessor :start_time

  def initialize
    @start_time = Time.now
  end

  # in seconds
  def elapsed
    Time.now - @start_time
  end

  def elapsed_str
    elapsed_str = "[#{'%.0f' % elapsed}s]"
  end

  def self.elapsed_exceeds?(name, duration_seconds)
    return true if Timer.get_elapsed(name).nil? || Timer.get_elapsed(name) > duration_seconds

    false
  end

  def self.get_elapsed(name)
    timestamp = get_timestamp(name)
    return Time.now - timestamp unless timestamp.nil?

    nil
  end

  def self.get_timestamp(name)
    dir = Rake.application.original_dir
    if File.exist?("#{DEV[:dev_root]}/log/#{name}.timestamp")
      return Time.parse(File.read("#{DEV[:dev_root]}/log/#{name}.timestamp").strip)
    end

    nil
  end

  def self.set_timestamp(name)
    Dir.mkdir("#{DEV_TASKS[:dev_root]}/log") unless Dir.exist?("#{DEV_TASKS[:dev_root]}/log")
    File.open("#{DEV_TASKS[:dev_root]}/log/#{name}.timestamp", 'w') { |f| f.puts(Time.now.to_s) }
  end
end

TIMER = Timer.new
