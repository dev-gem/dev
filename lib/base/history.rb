puts __FILE__ if defined?(DEBUG)

class History
	attr_accessor :dev

	def initialize dev=nil
		@dev=dev
		@dev=Dev.new if @dev.nil?
	end
	
	# .0. for 0 exit codes
	# .X. for non 0 exit codes
	# project name is contained in directory name
	def get_commands pattern
		commands=Array.new
		Dir.chdir(@dev.log_dir) do
			Dir.glob("*#{pattern}*.*.json").each{|logfile|
				commands << Command.new(JSON.parse(IO.read(logfile)))
			}
		end
		commands
	end

	def add_command command
		filename="#{@dev.log_dir}/#{command[:input]}.#{command[:exit_code]}/#{command[:directory].gsub(':','').gsub('/','-')}.json"
		File.open(filename,'w'){|f|f.write(rake_default.to_json)}
	end

	def get_wrk_command project_fullname
		commands=get_commands("rk-#{project_fullname}".gsub('/','-'))
		return commands[0] if commands.length > 0
		nil
	end
end