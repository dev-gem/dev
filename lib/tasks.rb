puts __FILE__ if defined?(DEBUG)

require 'rake'

class Tasks
	@@quiet=false

    def self.quiet
    	@@quiet
    end

    def self.execute value
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

	def self.execute_task task
		if(defined?(COMMANDS))
			if(COMMANDS.has_key?(task))
				puts "[:#{task}]" if(!Tasks.quiet)
		  		Tasks.execute(COMMANDS[task])
		    end
		end
	end
end

['add','analyze','build','clobber','commit',
 'doc','info','publish','pull','push','setup','test',
 'update','default'].each{|name| require_relative("tasks/#{name}.rb")}

