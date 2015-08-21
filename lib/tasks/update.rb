puts __FILE__ if defined?(DEBUG)

desc 'performs svn update'
task :update do Tasks.execute_task :update; end

class Update < Array
	def update
		self .add 'svn update' if File.exists?('.svn') && Internet.available?
	end
end