puts __FILE__ if defined?(DEBUG)

require 'fileutils'

class Dir
  def self.remove directory
    if(File.exists?(directory))
      begin
        FileUtils.rm_rf directory
        FileUtils.rm_r directory
      rescue
      end
    end
  end
end