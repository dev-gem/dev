class Version
	def self.read filename
		return "#{Gem::Specification.load(filename).version.to_s}" if filename.include?('.gemspec') 
		return IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)[0][0] if filename.include?('AssemblyInfo.cs')  
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