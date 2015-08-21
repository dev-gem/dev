puts __FILE__ if defined?(DEBUG)

require 'fileutils'

class File
	def self.amalgamate filename,source
		File.open(filename,'w'){|file|
			source.each{|source_file|
				file.puts IO.read(source_file)
			}
		}
	end

	def self.publish destination, source_dir, source_glob='**/*', overwrite_existing=false

		output = "\n"
		FileUtils.mkdir_p destination if !File.exists? destination

		files=nil
		Dir.chdir(source_dir) do
			files=FileList.new(source_glob).to_a
		end
		output = output + "\nfiles: #{files}.to_s"

		Dir.chdir(source_dir) do
			files.each{|f|
				file="#{destination}/#{f}"
				dirname=File.dirname(file)
				FileUtils.mkdir_p dirname if !File.exists? dirname
				FileUtils.cp(f,file) if !File.exists? file || overwrite_existing
			}
		end
		output
	end
end