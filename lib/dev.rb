puts __FILE__ if defined?(DEBUG)

require_relative('base.rb')
require_relative('apps.rb')
require_relative('tasks.rb')
require_relative('commands.rb')

PROJECT=Project.new()

class Dev
	attr_accessor :env,:projects,:commands

	def initialize env=nil
		@env=Environment.new(env) if !env.nil? && env.kind_of?(Hash)
		@env=Environment.new() if @env.nil?
		@projects=Projects.new(@env)
		@commands=Commands.new(@env)
	end
    
	def execute args
		args=args.split(' ') if(args.kind_of?(String))

		args.each{|arg|
		 	if(arg.include?('='))
		 		words=arg.split('=')
		 		if(words.length==2)
		 			ENV[words[0]]=words[1]
		 		end
		 	end
		}
		if args.length == 0
	       usage if args.length == 0
	    else
		   subcommand=args[0] if args.length > 0
		   subargs=Array.new
		   subargs=args[1,args.length-1] if args.length > 1

		   return projects.add(subargs) if subcommand=='add'
		   projects.clobber(subargs) if subcommand=='clobber'
		   projects.import(subargs) if subcommand=='import'
		   projects.list(subargs) if subcommand=='list'
		   projects.make(subargs) if subcommand=='make'
		   projects.info(subargs) if subcommand=='info'
		   projects.work(subargs) if subcommand=='work'
		   projects.update(subargs) if subcommand=='update'
		end
	end

	def usage
		puts 'usage: dev <subcommand> [options]'
		puts ''
		puts 'available subcommands'
		puts ' help'
		puts ' list'
		puts ' make'
		puts ' info'
		puts ' work'
		puts ''
		puts "Type 'dev help <subcommand>' for help on a specific subcommand.'"
	end
end

DEV=Dev.new