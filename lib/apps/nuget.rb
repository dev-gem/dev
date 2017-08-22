if defined?(DEBUG)
  puts DELIMITER
  puts __FILE__
  puts
  puts 'nuget not found' if(!Command.executes?('nuget')) 
  puts
end
#puts DELIMITER if defined?(DEBUG)
#puts __FILE__ if defined?(DEBUG)

class Nuget
	  def self.get_build_commands nuspec_file
      build_commands=nil
      if(File.exists?(nuspec_file))
      	build_commands=Array.new if build_commands.nil?
      	if(defined?(INCLUDE_REFERENCED_PROJECTS))
      		build_commands << "nuget pack #{nuspec_file} -IncludeReferencedProjects"
      	else
      	    build_commands << "nuget pack #{nuspec_file}"
        end
      end
      build_commands
    end

    def self.get_versions filename
      versions=Hash.new
      if(filename.include?('.nuspec'))
        nuspec_text=File.read(filename,:encoding=>'UTF-8')
        nuspec_text.scan(/<dependency[\s]+id="([\w\.]+)"[\s]+version="([\d\.]+)"/).each{|row|
          versions[row[0]] = row[1]
        }
        return versions
      end
      if(filename.include?('packages.config'))
        config_text=File.read(filename,:encoding=>'UTF-8')
        config_text.scan(/<package[\s]+id="([\w\.]+)"[\s]+version="([\d\.]+)"/).each{|row|
          versions[row[0]] = row[1]
        }
        return versions
      end
      versions
    end

    def self.set_versions filename,versions
      text=File.read(filename,:encoding=>'UTF-8')
      text_versions=text.scan(/id="[\w\.]+"[\s]+version="[\d\.]+"/)
      text2=text
      versions.each{|k,v|
        text_versions.each{|line|
          if(line.include?("\"#{k}\""))
            new_line = "id=\"#{k}\" version=\"#{v}\""
            text2 = text2.gsub(line,new_line)
          end
        }
      }
      unless text==text2
          File.open(filename,"w") { |f| f.puts text2 }
        end
    end

    def self.update_versions(source_filename,destination_filename)
      old_versions=Nuget.get_versions(destination_filename)
      source_versions=Nuget.get_versions(source_filename)
      new_versions=Hash.new
      old_versions.each{|k,v|
        if(source_versions.has_key?(k))
          new_versions[k]=source_versions[k]
        end
      }
      Nuget.set_versions(destination_filename,new_versions)
    end
end