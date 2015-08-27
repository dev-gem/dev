class Version
	def self.extract text
		[/[Vv]ersion\s*=\s*['"]([\d.]+)['"]/,
		 /Version\(\s*"([\d.]+)"\s*\)/].each{|regex|
			scan=text.scan(regex)
			if(!scan.nil?)
				return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
			end
		}
		nil
	end

	def self.extract_from_file filename
		Version.extract IO.read(filename)
	end

	def self.extract_from_filelist filelist
		version=nil
		filelist.each{|f|
			version=extract_from_file f
			return version if !version.nil?
		}
		nil
	end

    def self.update_text text, version
    	text=text.gsub(/version\s*=\s*'[\d.]+'/,"version='#{version}'")
    	text=text.gsub(/version\s*=\s*"[\d.]+"/,"version=\"#{version}\"")
    	text=text.gsub(/Version\s*=\s*'[\d.]+'/,"Version='#{version}'")
    	text=text.gsub(/Version\s*=\s*"[\d.]+"/,"Version=\"#{version}\"")
    	text=text.gsub(/Version\(\s*"[\d.]+"\s*\)/,"Version(\"#{version}\")")
    	text=text.gsub(/Name\s*=\s*"Version"\s*Value\s*=\s*"[\d.]+"/,"Name=\"Version\" Value=\"#{version}\"")
    end

	def self.update_file filename, version
		if(File.exists?(filename))
			orig=IO.read(filename)
			text=Version.update_text orig,version
			File.open(filename,'w'){|f|f.write(text)} if(orig!=text)
		end
	end

	def self.update_filelist filelist,version
		filelist.each{|f|
			Version.update_file f,version
		}
	end

	def self.read filename
		return "#{Gem::Specification.load(filename).version.to_s}" if filename.include?('.gemspec') 
		if filename.include?('AssemblyInfo.cs')  
			scan=IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)
			if(!scan.nil?)
				return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
			end
		   #return IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)[0][0] 
		   scan=IO.read(wxs).scan(/Version=\"([\d.]+)\"/)
		   if(!scan.nil?)
		        return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
		   end
	    end
		'0.0.0'
	end

	def self.get_version
		Dir.glob('**/*.gemspec').each{|gemspec|
			return Version.read gemspec
		}
		Dir.glob('**/AssemblyInfo.cs').each{|assemblyInfo|
			return Version.read assemblyInfo
		}
		Dir.glob('**/*.wxs').each{|wxs|
			return Version.read wxs
		}
		'0.0.0'
	end
end

VERSION=Version.get_version if !defined? VERSION