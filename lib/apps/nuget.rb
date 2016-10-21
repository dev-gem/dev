puts __FILE__ if defined?(DEBUG)

class Nuget
	def self.get_build_commands nuspec_file
      build_commands=nil
      if(File.exists?(nuspec_file))
      	build_commands=Array.new if build_commands.nil?
      	if(defined?(INCLUDE_REFERENCED_PROJECTS))
      		build_commands << "nuget pack #{nuspec_file} -IncludeReferencedProjects"
      	else
      	    build_commands << "nuget pack #{nuspec_file} -Symbols"
        end
      end
      build_commands
    end
end