puts __FILE__ if defined?(DEBUG)

desc 'performs svn update'
task :update do Tasks.execute_task :update; end

class Update < Array
	def update
		self .add 'svn update' if File.exists?('.svn') && Internet.available?

		if(Dir.glob('**/packages.config').length > 0)
			Dir.glob('*.sln').each{|sln_file|
				add "nuget update #{sln_file}"
			}
		end
	end
end