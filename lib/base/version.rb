class Version
	def self.read filename
		return "#{Gem::Specification.load(filename).version.to_s}" if filename.include?('.gemspec') 
		if filename.include?('AssemblyInfo.cs')  
			scan=IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)
			if(!scan.nil?)
				return scan[0][0] if(scan.length > 0 && !scan[0].nil? && scan[0].length > 0)
			end
		   #return IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)[0][0] 
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
		'0.0.0'
	end
end

if !defined? VERSION
	Dir.glob('**/*.gemspec').each{|gemspec|
		if !defined? VERSION
			VERSION=Version.read gemspec
		end
	}
	Dir.glob('**/AssemblyInfo.cs').each{|assemblyInfo|
		if !defined? VERSION
			VERSION=Version.read assemblyInfo
		end
	}
end