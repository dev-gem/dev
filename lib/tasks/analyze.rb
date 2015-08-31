puts __FILE__ if defined?(DEBUG)

desc 'performs analyze commands'
task :analyze do Tasks.execute_task :analyze;end

class Analyze < Array
	def update
		if(`gem list countloc`.include?('countloc ('))
			FileUtils.mkdir('doc') if(!File.exists?('doc'))
			add_quiet 'countloc -r * --html doc/countloc.html'
		end
	end
end