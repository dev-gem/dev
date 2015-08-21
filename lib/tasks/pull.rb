puts __FILE__ if defined?(DEBUG)


desc 'performs a git pull'
task :pull do Tasks.execute_task :pull; end

class Pull < Array
	def update
		if(Internet.available?)
			if(File.exists?('.git') && `git config --list`.include?('user.name='))
				self <<  'git pull' if Git.branch != 'develop'
			end
		end
	end
end