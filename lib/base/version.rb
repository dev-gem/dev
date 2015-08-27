class Version
	def self.extract text
		[/[Vv]ersion\s*=\s*['"]([\d.]+)['"]/,
		 /Version\(\s*"([\d.]+)"\s*\)/].each{|regex|
			scan=text.scan(regex)#/version\s*=\s*'([\d.]+)'/)#regex)
			if(!scan.nil?)
				return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
			end
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
			text=IO.read(filename)
			orig=text
			text.gsub(//,'version="#{version}')
		end
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