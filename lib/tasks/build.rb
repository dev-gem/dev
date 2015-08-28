puts __FILE__ if defined?(DEBUG)

require_relative('../base/environment.rb')

desc 'performs build commands'
task :build do Tasks.execute_task :build;end
#task :build do Tasks.execute_task :build;end

SLN_FILES=FileList.new('*.sln','*/*.sln','*/*/*.sln')
NUGET_FILES=FileList.new('**/*.nuspec')
WXS_FILES=FileList.new('**/*.wxs')

class Build < Array
	def update

		#changed = true
        #if(changed)
        	puts "Build scanning for sln files" if Environment.default.debug?
			Dir.glob('*.gemspec'){|gemspec|
	    		add "gem build #{gemspec}" if !File.exist?(Gemspec.gemfile gemspec)
	    	}
	    	
	    	puts "Build scanning for sln files" if Environment.default.debug?
	    	SLN_FILES.each{|sln_file|

	    		build_commands = MSBuild.get_build_commands sln_file
	    		if(!build_commands.nil?)
	    			build_commands.each{|c|
	    				self.add c
	    			}
	    		end
	    	}

            puts "Build scanning for nuget files" if Environment.default.debug?
	    	NUGET_FILES.each{|nuget_file|
	    		build_commands = Nuget.get_build_commands nuget_file
	    		if(!build_commands.nil?)
	    			build_commands.each{|c|
	    				self.add c
	    			}
	    		end
	    	}

            puts "Build scanning for wxs <Product> files" if Environment.default.debug?
	    	WXS_FILES.each{|wxs_file|
	    		if(IO.read(wxs_file).include?('<Product'))
	    		  build_commands = Wix.get_build_commands wxs_file
	    		  if(!build_commands.nil?)
	    			build_commands.each{|c|
	    				self.add c
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
	    				self.add c
	    			}
	    		  end
	    	    end
	    	}
	    #end
	end
end