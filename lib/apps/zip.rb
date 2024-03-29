# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require "zip"
require "fileutils"

module Zip
  # exports a zip file to a destination directory
  # zip_file full path to a zip file to be exported
  # destination directory where the zip file contents are to be placed
  def self.export(zip_file, destination)
    raise "#{zip_file} does not exist." unless ::File.exist?(zip_file)

    unzip(zip_file, destination) unless Dir.exist?(destination)
    sleep(0.5) # I guess we need to give the OS some time to get things in order?
  end

  # publish a directory to a file path
  # source_dir is the directory with the files to be published
  # destination is the zip file path
  # source_glob is a string or array of glob directives to specify files in source_dir to be publish
  # source_glob defaults to '**/*' to publish all files in the source_dir
  def self.publish(source_dir, destination, source_filelist = FileList.new("**/*"))
    Dir.mktmpdir do |dir| # Build zip file locally
      tmp_file_name = "#{dir}/#{::File.basename(destination)}"

      zip(source_dir, source_filelist, tmp_file_name)

      destination_dir = ::File.dirname(destination)
      FileUtils.mkpath(destination_dir) unless Dir.exist?(destination_dir)

      FileUtils.cp(tmp_file_name, destination)
    end
  end

  def self.zip(base_directory, files_to_archive, zip_file)
    FileUtils.mkpath(::File.dirname(zip_file)) unless Dir.exist?(::File.dirname(zip_file))
    io = Zip::File.open(zip_file, Zip::File::CREATE)

    files_to_archive.each do |file|
      io.get_output_stream(file) { |f| f.puts(::File.open("#{base_directory}/#{file}", "rb").read) }
    end

    io.close
  end

  def self.unzip(zip_file, destination)
    FileUtils.mkpath(destination) unless Dir.exist?(destination)
    Zip::File.open(zip_file) do |files|
      files.each do |entry|
        destination_file = "#{destination}/#{entry.name}"

        directory = ::File.dirname(destination_file)
        FileUtils.mkpath(directory) unless Dir.exist?(directory)

        entry.extract(destination_file)
      end
    end
  end
end
