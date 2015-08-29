puts __FILE__ if defined?(DEBUG)

require 'fileutils'

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
      puts "directory #{directory} is empty" 
      return true
    end
    puts "directory #{directory} is not empty"
    false
  end
  #def self.remove_empty directory, recursive=false
  #  if(File.exists?(directory))
  #    if(recursive)
  #      Dir.chdir(directory) do
  #        Dir.glob('*').select {|f| File.directory? f}.each{|d|
  #          Dir.remove_empty(d,true)
  #          remove d if (Dir.entries(d) - %w{ . .. }).empty?
  #        }
  #      end
  #    end

  #    remove directory if (Dir.entries(directory) - %w{ . .. }).empty?
  #  end
  #end
end