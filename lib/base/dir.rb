require 'fileutils'

if Gem::Specification::find_all_by_name('zip').any?
  require 'zip'
end

class Dir
  def self.make directory
  	FileUtils.mkdir_p directory if !File.exists? directory
  end
  def self.remove directory, remove_empty_parents=false
    begin
      FileUtils.rm_rf directory if(!Dir.empty?(directory))
      FileUtils.rm_r directory  if(File.exists?(directory))
      if(remove_empty_parents)
        parent_dir=File.dirname(directory)
        Dir.remove parent_dir, true if(Dir.empty?(parent_dir))
      end
    rescue
    end
  end
  def self.empty? directory
    if((Dir.entries(directory) - %w{ . .. }).empty?)
      return true
    end
    false
  end

  def self.get_latest_mtime directory
    mtime=Time.new(1980)
    Dir.chdir(directory)  do
      latest_filename=''
      Dir.glob('**/*.*').each{|f|
        if mtime.nil? || File.mtime(f) > mtime
          mtime=File.mtime(f) 
          latest_filename=f
        end
      }
      puts "   latest_mtime #{mtime.to_s} #{latest_filename}" if Environment.default.debug?
    end
    mtime
  end

  def self.zip_source(directory,glob_pattern,zipfilename)
    if Gem::Specification::find_all_by_name('zip').any?
      File.delete(zipfilename) if(File.exists?(zipfilename))
      Zip::File.open(zipfilename,Zip::File::CREATE) do |zipfile|
        Dir.chdir(directory) do
          count = 0
          Dir.glob(glob_pattern).each{|source_file|
            zipfile.add(source_file,"#{File.dirname(__FILE__)}/#{directory}/#{source_file}")
            count = count + 1
          }
          puts "added #{count} files to #{zipfilename}"
        end
      end
    else
      puts "rubyzip gem is not installed 'gem install rubyzip'"
    end
end

def self.unzip(zipfilename,directory)
  if Gem::Specification::find_all_by_name('rubyzip').any?
    Zip::File.open(zipfilename) do |zip_file|
      zip_file.each do |entry|
        puts entry
        dest = "#{directory}/#{entry.to_s}"
        parent_dir=File.dirname(dest)
        FileUtils.mkdir_p parent_dir if(!Dir.exists?(parent_dir))
        entry.extract("#{directory}/#{entry.to_s}")
      end
    end
  else
    puts "rubyzip gem is not installed 'gem install rubyzip'"
  end
end
end