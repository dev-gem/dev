puts __FILE__ if defined?(DEBUG)

require_relative('../base/environment.rb')

desc 'performs build commands'
task :build do Tasks.execute_task :build;end

SLN_FILES=FileList.new('*.sln','*/*.sln','*/*/*.sln')
NUGET_FILES=FileList.new('**/*.nuspec')
WXS_FILES=FileList.new('**/*.wxs')
SMARTASSEMBLY_FILES=FileList.new('**/*.saproj')

class Build < Array
	def update
    	update_gemspec
		update_sln if Environment.windows?
		update_smartassembly if Environment.windows?
    	update_nuget if Environment.windows?
    	update_wix if Environment.windows?
        update_xcode if Environment.mac?
	end

    def update_gemspec
    	puts "Build scanning for gemspec files" if Environment.default.debug?
		Dir.glob('*.gemspec'){|gemspec|
	    	add_quiet("gem build #{gemspec}") if !File.exist?(Gemspec.gemfile gemspec)
	    }
    end

	def update_sln
		puts "Build scanning for sln files" if Environment.default.debug?
		SLN_FILES.each{|sln_file|
			puts "  #{sln_file}" if Environment.default.debug?
			build_commands = MSBuild.get_build_commands sln_file
			if(!build_commands.nil?)
				build_commands.each{|c|
					puts "  build command #{c} discovered." if Environment.default.debug?
					add_quiet(c)
				}
			else
				puts "  no build command discovered." if Environment.default.debug?
			end
		}
	end

	def update_smartassembly
		puts "Build scanning for sa (smart assembly) files" if Environment.default.debug?
		sa = 'C:/Program Files/Red Gate/SmartAssembly 6/SmartAssembly.com'
		SMARTASSEMBLY_FILES.each{|saproj_file|
			puts "  #{saproj_file}" if Environment.default.debug?
			if(!File.exists?(sa))
				puts "warning: #{sa} does not exist, skipping build command for #{saproj_file}"
			else
				add_quiet("\"#{sa}\" /build #{saproj_file}")
			end
		}
	end

	def update_nuget
		puts "Build scanning for nuget files" if Environment.default.debug?
	   	NUGET_FILES.each{|nuget_file|
	    	build_commands = Nuget.get_build_commands nuget_file
	    	if(!build_commands.nil?)
	    		build_commands.each{|c|
	    			add_quiet(c)
	    		}
	    	end
	    }
	end

	def update_wix
		puts "Build scanning for wxs <Product> files" if Environment.default.debug?
		WXS_FILES.each{|wxs_file|
			if(IO.read(wxs_file).include?('<Product'))
			  build_commands = Wix.get_build_commands wxs_file
			  if(!build_commands.nil?)
				build_commands.each{|c|
					add_quiet(c)
				}
			  end
			end
		}

		puts "Build scanning for wxs <Bundle> files" if Environment.default.debug?
		WXS_FILES.each{|wxs_file|
			if(IO.read(wxs_file).include?('<Bundle'))
			  build_commands = Wix.get_build_commands wxs_file
			  if(!build_commands.nil?)
				build_commands.each{|c|
					add_quiet(c)
				}
			  end
			end
		}
	end
	def update_xcode
		puts "Build scanning for xcodeproj folders" if Environment.default.debug?
	    Dir.glob('**/*.xcodeproj').each{|dir|
	        puts dir if Environment.default.debug?
	        build_commands = XCodeBuild.get_build_commands dir
	        if(!build_commands.nil?)
	        	build_commands.each{|c|
	    			build_commands << c
	    		}
	    	end
	     }
	end
end