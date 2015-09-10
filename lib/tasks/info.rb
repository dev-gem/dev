desc 'displays project info'
task :info do
	Environment.default.info
	puts ' '
	PROJECT.info
	puts ' '
	COMMANDS.info
end

