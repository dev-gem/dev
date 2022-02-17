# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require "fileutils"

class File
  def self.amalgamate(filename, source)
    File.open(filename, "w") do |file|
      source.each do |source_file|
        file.puts IO.read(source_file)
      end
    end
  end

  # overwrite_existing=false
  def self.publish(destination, source_dir, source_glob = "**/*", exclude_glob = nil)
    output = "\n"
    FileUtils.mkdir_p destination unless File.exist? destination

    files = nil
    Dir.chdir(source_dir) do
      files = FileList.new(source_glob).to_a
      unless exclude_glob.nil?
        FileList.new(exclude_glob).to_a.each do |f|
          files.delete(f) if files.include?(f)
        end
      end
    end
    output += "\nfiles: #{files}.to_s"

    Dir.chdir(source_dir) do
      files.each do |f|
        file = "#{destination}/#{f}"
        dirname = File.dirname(file)
        FileUtils.mkdir_p dirname unless File.exist? dirname
        FileUtils.cp(f, file) unless File.exist? file # || overwrite_existing
      end
    end
    output
  end
end
