puts __FILE__ if ENV.has_key?('DEBUG')

require_relative('base/environment.rb')
require_relative('base/projects.rb')
require_relative('commands.rb')


class Dev
	attr_accessor :env,:projects,:commands

	def initialize env=nil
		@env=Environment.new(env) if !env.nil? && env.kind_of?(Hash)
		@env=Environment.new() if @env.nil?
		@projects=Projects.new(@env)
		@commands=Commands.new(@env)
		@output=''
	end
    
	def execute args
		args=args.split(' ') if(args.kind_of?(String))

        # parse arguments that are of the form KEY=VALUE
		args.each{|arg|
		 	if(arg.include?('='))
		 		words=arg.split('=')
		 		if(words.length==2)
		 			ENV[words[0]]=words[1]
		 		end
		 	end
		}

		if args.length == 0
	       return usage
	    else
		   subcommand=args[0] if args.length > 0
		   subargs=Array.new
		   subargs=args[1,args.length-1] if args.length > 1

		   return projects.add(subargs) if subcommand=='add'
		   return projects.clobber(subargs) if subcommand=='clobber'
		   return projects.import(subargs) if subcommand=='import'
		   return projects.list(subargs) if subcommand=='list'
		   return projects.make(subargs) if subcommand=='make'
		   return projects.info(subargs) if subcommand=='info'
		   return projects.remove(subargs) if subcommand=='remove'
		   return projects.work(subargs) if subcommand=='work'
		   return projects.update(subargs) if subcommand=='update'

		   @env.out "unknown command: '#{subcommand}'"
		   1
		end
	end

	def usage
		return 0
		@env.out 'usage: dev <subcommand> [options]'
		@env.out ''
		@env.out 'available subcommands'
		@env.out ' help'
		@env.out ' list'
		@env.out ' make'
		@env.out ' info'
		@env.out ' work'
		@env.out ''
		@env.out "Type 'dev help <subcommand>' for help on a specific subcommand.'"
		0
	end
end

require_relative('base.rb')
#require_relative('apps.rb')
require_relative('tasks.rb')
require_relative('commands.rb')

puts "defining DEV" if Environment.default.debug?
DEV=Dev.new
require_relative('tasks/default.rb')

