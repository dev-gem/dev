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
					#---
					list_output = %x[svn list -R]
	        status_output = %x[svn status]
	        status_output = status_output.gsub(/\\/,"/")
					#---
					SOURCE.each{|f|
						if(File.exists?(f) && File.file?(f) && !list_output.include?(f))
							if(m = status_output.match(/^(?<action>.)\s+(?<file>#{f})$/i))
			          if(m[:file] == f && m[:action] == '?')
									add_quiet "svn add \"#{f}\" --parents"
			          end
		          end
            end
						#	if(f.include?(' '))
	          #    status=Command.output("svn status \"#{f}\"") 
	          #    error=Command.error("svn status \"#{f}\"")
	          #  else
	          #    status=Command.output("svn status #{f}") 
	          #    error=Command.error("svn status #{f}")
	          #  end
	          #  if(status.include?('?') || status.include?('was not found') || error.include?('was not found'))
	          #    if(f.include?(' '))
						#		  add_quiet "svn add \"#{f}\" --parents"
						#	  else
						#		  add_quiet "svn add #{f} --parents"
						#	  end
						#	end
						#end
					}
				end
				if(File.exists?('.git'))
					SOURCE.each{|f|
						if(File.exists?(f) && File.file?(f))
						  status=Command.output("git status #{f} --short")
						  if status.include?('??') || status.include?(' M ')
							  add_quiet "git add #{f} -v" 
						  end
					  end
					}
				end
			end
		end
	end
end