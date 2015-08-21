puts __FILE__ if defined?(DEBUG)

require_relative('base.rb')
require_relative('apps.rb')
require_relative('tasks.rb')
require_relative('commands.rb')

if(File.exists?(Environment.configuration))
  require Environment.configuration
end

PROJECT=Project.new()

class Dev
	def self.execute args
		puts 'dev'
		puts "args: #{args.to_s}"

		PROJECTS.show(args.length>1 ? args[1]:'') if args.length > 0 && args[0] == 'list'
	end
end

