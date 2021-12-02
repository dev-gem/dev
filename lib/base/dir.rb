# frozen_string_literal: true

require 'fileutils'

class Dir
  def self.make(directory)
    FileUtils.mkdir_p directory unless File.exist? directory
  end

  def self.remove(directory, remove_empty_parents = false)
    FileUtils.rm_rf directory unless Dir.empty?(directory)
    FileUtils.rm_r directory  if File.exist?(directory)
    if remove_empty_parents
      parent_dir = File.dirname(directory)
      Dir.remove parent_dir, true if Dir.empty?(parent_dir)
    end
  rescue StandardError
  end

  def self.empty?(directory)
    return true if (Dir.entries(directory) - %w[. ..]).empty?

    false
  end

  def self.get_latest_mtime(directory)
    mtime = Time.new(1980)
    Dir.chdir(directory) do
      latest_filename = ''
      Dir.glob('**/*.*').each do |f|
        if mtime.nil? || File.mtime(f) > mtime
          mtime = File.mtime(f)
          latest_filename = f
        end
      end
      puts "   latest_mtime #{mtime} #{latest_filename}" if Environment.default.debug?
    end
    mtime
  end

  def self.get_project_name(directory)
    name = directory.split('/').last
    rakefile = "#{directory}/rakefile.rb"
    if File.exist?(rakefile)
      txt = IO.read(rakefile)
      if txt.include?('NAME=')
        scan = txt.scan(/NAME=['"]([\w.]+)/)
        name = scan[0][0] if !scan.nil? && (scan.length.positive? && !scan[0].nil? && scan[0].length.positive?)
      end
    end
    name
  end

  def self.zip(directory, files, zipfilename)
    if Gem::Specification.find_all_by_name('rubyzip').any?
      require 'zip'
      File.delete(zipfilename) if File.exist?(zipfilename)
      Zip::File.open(zipfilename, Zip::File::CREATE) do |zipfile|
        Dir.chdir(directory) do
          count = 0
          files.each  do |source_file|
            zipfile.add(source_file, "#{directory}/#{source_file}")
            count += 1
          end
          puts "added #{count} files to #{zipfilename}"
        end
      end
    else
      puts "rubyzip gem is not installed 'gem install rubyzip'"
    end
  end

  def self.unzip(zipfilename, directory)
    if Gem::Specification.find_all_by_name('rubyzip').any?
      require 'zip'
      count = 0
      Zip::File.open(zipfilename) do |zip_file|
        zip_file.each do |entry|
          dest = "#{directory}/#{entry}"
          parent_dir = File.dirname(dest)
          FileUtils.mkdir_p parent_dir unless Dir.exist?(parent_dir)
          entry.extract("#{directory}/#{entry}")
          count += 1
        end
      end
      puts "extracted #{count} files to #{directory}"
    else
      puts "rubyzip gem is not installed 'gem install rubyzip'"
    end
  end

  def self.copy_files(src_dir, glob_pattern, exclude_patterns, target_dir)
    if Dir.exist?(src_dir)
      Dir.chdir(src_dir) do
        Dir.glob(glob_pattern).each do |f|
          next unless File.file?(f)

          exclude = false
          exclude_patterns&.each do |p|
            exclude = true if f.include?(p)
          end
          next if exclude

          dest = "#{target_dir}/#{f}"
          FileUtils.mkdir_p(File.dirname(dest)) unless Dir.exist?(File.dirname(dest))
          FileUtils.cp(f, dest)
        end
      end
    end
  end
end
