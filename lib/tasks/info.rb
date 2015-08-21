puts __FILE__ if defined?(DEBUG)

desc 'displays project info'
task :info do
	Environment.info
	puts ' '
	PROJECT.info
	puts ' '
	COMMANDS.info
end

