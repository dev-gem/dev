puts __FILE__ if defined?(DEBUG)

desc 'performs documentation commands'
task :doc do Tasks.execute_task :doc;end

class Doc < Array
	def update
		if(Command.exit_code('yard --version'))
		  add 'yard doc - LICENSE' if File.exists?('README.md') && File.exists?('LICENSE')
		end
	end
end