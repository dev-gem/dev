puts __FILE__ if defined?(DEBUG)

desc 'adds source files to git or subversion'
task :add do Tasks.execute_task :add;end

class Add < Array
	def update
		if(File.exists?('.git') && File.exists?('.gitignore'))
			add_quiet 'git add --all' 
		else
			if(defined?(SOURCE))
				if(File.exists?('.svn'))
					SOURCE.each{|f|
						if(File.exists?(f) && File.file?(f))
							if(f.include?(' '))
	                          status=Command.output("svn status \"#{f}\"") 
	                          error=Command.error("svn status \"#{f}\"")
	                        else
	                          status=Command.output("svn status #{f}") 
	                          error=Command.error("svn status #{f}")
	                   	    end
	                        if(status.include?('?') || status.include?('was not found') || error.include?('was not found'))
	                        	if(f.include?(' '))
								  #puts "svn add \"#{f}\" --parents"
								  add_quiet add "svn add \"#{f}\" --parents"
							    else
							      #puts "svn add #{f} --parents"
								  add_quiet "svn add #{f} --parents"
							    end
							end
						end
					}
				end
				if(File.exists?('.git'))
					SOURCE.each{|f|
						if(File.exists?(f) && File.file?(f))
						  status=`git status #{f} --short`
						  if status.include?('??') || status.include?(' M ')
							#puts "git add #{f} -v"
							add_quiet "git add #{f} -v" 
						  end
					    end
					}
				end
			end
		end
	end
end