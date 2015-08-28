puts __FILE__ if defined?(DEBUG)

require 'rake'
#require 'ansi/code'

class Tasks
	attr_accessor :env
	@@default=nil

	def initialize env=nil
		@@default=self
		@env=env
		@env=Environment.new if @env.nil?
	end

    def execute value
	  if(value.respond_to?(:execute))
	    value.update if value.respond_to?(:update)
	    value.execute
	  else
	    if(value.is_a?(String))
	      puts `#{value}`
	    else
	      if(value.is_a?(Array))
	        value.each{|e| execute(e)}
	      end
	    end
	    end
	end

	def execute_task task
		if(defined?(COMMANDS))
			if(COMMANDS.has_key?(task))
				puts "[:#{task}]" if !@env.colorize?
				puts "[" + ANSI.blue + ANSI.bright + ":#{task}" + ANSI.reset + "]" if @env.colorize?
		  		execute(COMMANDS[task])
		    end
		end
	end

	def self.execute_task task
		@@default=Tasks.new if @@default.nil?
		@@default.execute_task task
	end
end

['add','analyze','build','clobber','commit',
 'doc','info','publish','pull','push','setup','test',
 'update','default'].each{|name| require_relative("tasks/#{name}.rb")}

