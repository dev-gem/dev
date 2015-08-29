puts __FILE__ if defined?(DEBUG)

require 'fileutils'

class Dir
  def self.make directory
  	FileUtils.mkdir_p directory if !File.exists? directory
  end
  def self.remove directory, remove_empty_parents=false
    if(File.exists?(directory))
      begin
        FileUtils.rm_rf directory
        FileUtils.rm_r directory
        if(remove_empty_parents)
          if(Dir.empty?(File.dirname(directory)))
            Dir.remove(File.dirname(directory),true)
          end
        end
      rescue
      end
    end
  end
  def self.empty? directory
    (Dir.entries(directory) - %w{ . .. }).empty?
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