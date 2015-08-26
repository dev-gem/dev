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
	@env=Hash.new
	def get_env key
		return env[key] if env.has_key? key
		ENV[key]
	end
	def set_env key,value
		env[key]=value
	end
	def execute args
		if(args.kind_of?(String))
			args=args.split(' ')
		end
		projects=Projects.new
		projects.open Projects.user_projects_filename if File.exists? Projects.user_projects_filename
		projects.add(args) if args.length > 0 && args[0] == 'add'
		projects.import(args.length>1 ? args[1]:'') if args.length > 0 && args[0] == 'import'
		projects.list(args.length>1 ? args[1]:'') if args.length > 0 && args[0] == 'list'
		projects.make(args) if args.length > 0 && args[0] == 'make'
		projects.work(args) if args.length > 0 && args[0] == 'work'
		projects.update(args) if args.length > 0 && args[0] == 'update'
		usage if args.length == 0
	end

	def usage
		puts 'Usage:'
		puts ' list [pattern]'
	end
end

DEV=Dev.new