desc 'performs a git pull'
task :pull do Tasks.execute_task :pull; end

class Pull < Array
	def update
		if(File.exists?('.git') && `git config --list`.include?('user.name=') )
			add_passive('git pull') if Git.branch == 'master'
		end
	end
end