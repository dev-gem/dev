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
	attr_accessor :projects,:history,:db

	def initialize env=nil
		@env=Hash.new
		@env_aliases={'HOME' => ['USERPROFILE'],
		          'DEV_ROOT' => ['DEV_HOME','HOME','USERPROFILE']
		}
		env.each{|k,v| @env[k.to_s]=v} if !env.nil?
		@projects=Projects.new(self)
		@history=History.new(self)
	end

    #def filename
    #	"#{@dev.get_env('DEV_ROOT')}/dev.sql"
    #end
    def root_dir
    	get_env('DEV_ROOT')
    end

    def log_dir
    	dir="#{get_env('DEV_ROOT')}/log"
    	FileUtils.mkdir_p dir if !File.exists? dir
    	dir
    end

    def wrk_dir
    	dir="#{get_env('DEV_ROOT')}/wrk"
    	FileUtils.mkdir_p dir if !File.exists? dir
    	dir
    end

	def reset
		@projects=nil
	end

	def get_env key
		if(!@env.nil? && @env.has_key?(key))
		  return @env[key] 
	    end
		value = ENV[key]
		if(value.nil?)
			if(@env_aliases.has_key?(key))
				@env_aliases[key].each{|akey|
					value=get_env(akey) if value.nil?
				}
			end
		end
		value
	end

	def debug?
		return true if get_env('DEBUG')=='true'
		false
	end
    
	def execute args
		puts "\nDEV.execute #{args}\n" if debug?
		args=args.split(' ') if(args.kind_of?(String))
		#	args=args.split(' ')
		#end
		if args.length == 0
	       usage if args.length == 0
	    else
		   subcommand=args[0] if args.length > 0
		   subargs=Array.new
		   subargs=args[1,args.length-1] if args.length > 1

           puts "subcommand #{subcommand}"# if defined? DEBUG
		   projects.add(subargs) if subcommand=='add'
		   projects.import(subargs) if subcommand=='import'
		   projects.list(subargs) if subcommand=='list'
		   projects.make(subargs) if subcommand=='make'
		   projects.work(subargs) if subcommand=='work'
		   projects.update(subargs) if subcommand=='update'
		end
	end
		#projects=Projects.new
		#projects.open Projects.user_projects_filename if File.exists? Projects.user_projects_filename
		#projects.add(subcommand,subargs) if subcommand=='add'#args.length > 0 && args[0] == 'add'
		#projects.import(subcommand,subargs) if subcommand=='import'#args.length>1 ? args[1]:'') if args.length > 0 && args[0] == 'import'
		#projects.list(subcommand,subargs) if subcommand=='list'#args.length>1 ? args[1]:'') if args.length > 0 && args[0] == 'list'
		#projects.make(subcommand,subargs) if subcommand=='make'#(args) if args.length > 0 && args[0] == 'make'
		#projects.work(args) if args.length > 0 && args[0] == 'work'
		#projects.update(args) if args.length > 0 && args[0] == 'update'
		
	#    end
	#end

	def usage
		puts 'Usage:'
		puts ' list [pattern]'
	end
end

DEV=Dev.new