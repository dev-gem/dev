puts __FILE__ if defined?(DEBUG)

desc 'commits source files to git or subversion'
if(File.exists?('git'))
  task :commit=>[:add] do Tasks.execute_task :commit; end
else
  task :commit=>[:add] do Tasks.execute_task :commit;end
end

class Commit < Array
	def update
		message=""
		message=IO.read('commit.message').strip if File.exists?('commit.message')

		if(File.exists?('.git') && `git config --list`.include?('user.name=') && Git.user_email.length > 0)
			if(!`git status`.include?('nothing to commit') &&
			   !`git status`.include?('untracked files present') &&
			   !`git status`.include?('no changes add to commit'))
			  if(message.length==0)
				if(defined?(REQUIRE_COMMIT_MESSAGE))
					Commit.reset_commit_message
					raise "commit.message required to perform commit"
				else
			  		add_passive "git commit -m'all'"
			  	end
			  else
			    add_quiet "git commit -a -v --file commit.message"
			    add_quiet "<%Commit.reset_commit_message%>"
			  end
		    end 		
		end
		if(File.exists?('.svn'))
			if(message.length==0)
				if(defined?(REQUIRE_COMMIT_MESSAGE))
					Commit.reset_commit_message
					raise "commit.message required to perform commit"
				else
					add_quiet 'svn commit -m"commit all"'
				end
			else
				add_quiet 'svn commit --file commit.message'
				add_quiet "<%Commit.reset_commit_message%>"
			end
		end

		log_debug_info("Commit") if defined?(DEBUG)
	end

	def self.reset_commit_message
		File.open('commit.message','w'){|f|f.write('')}
	end
end