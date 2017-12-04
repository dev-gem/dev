puts __FILE__ if defined?(DEBUG)

require 'zip'
require 'fileutils'

module Zip
  extend self
  # exports a zip file to a destination directory
  # zip_file full path to a zip file to be exported
  # destination directory where the zip file contents are to be placed
  def self.export zip_file, destination
    raise "#{zip_file} does not exist." unless(IO::File.exists?(zip_file))
    unzip(zip_file, destiation) unless(Dir.exists?(destination))
  end

  # publish a directory to a file path
  # source_dir is the directory with the files to be published
  # destination is the zip file path
  # source_glob is a string or array of glob directives to specify files in source_dir to be publish
  # source_glob defaults to '**/*' to publish all files in the source_dir
  def self.publish destination, source_dir, source_filelist=FileList.new('**/*')
    Dir.mktmpdir do |dir|
      tmp_file_name = "#{dir}/#{IO::File.basename(destination)}"
      
      zip(source_dir, source_filelist, tmp_file_name)
      
      destination_dir = IO::File.dirname(destination)
      FileUtils.mkpath(destination_dir) unless(Dir.exists?(destination_dir))
      
      FileUtils.cp(tmp_file_name, destination)
    end
  end

  private
  def self.zip(base_directory, files_to_archive, zip_file) 
    FileUtils.mkpath(IO::File.dirname(zip_file)) unless(Dir.exists?(IO::File.dirname(zip_file)))
    io = Zip::File.open(zip_file, Zip::File::CREATE); 
  
    files_to_archive.each do |file|
      io.get_output_stream(file) { |f| f.puts(IO::File.open("#{base_directory}/#{file}", "rb").read())} 
    end
  
    io.close(); 
  end 		

  def self.unzip(zip_file, destination)
    Zip::File.open(zip_file) do |files|
      files.each do |entry|
        puts "Extracting #{entry.name}"
        entry.extract("#{destination}/#{entry.name}")
      end
    end
  end
end
