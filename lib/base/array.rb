require_relative('environment.rb')
class Array
    attr_accessor :env
    def initialize env=nil
      @env=env
      @env=Environment.new() if @env.nil? 
      @env=Environmnet.new() if !@env.kind_of?(Environment)
    end

    def execute value=nil
      @env=Environment.new() if @env.nil? 
      i=0
      #puts "Array.execute length=#{self.length}" if defined?(DEBUG)
      while i < self.length

        #puts self[i].to_s if defined?(DEBUG)
        #puts "Array[#{i.to_s}]'=nil" if @env.debug? && self[i].nil?
        #puts "Array[#{i.to_s}].class=#{self[i].class.to_s}" if @env.debug? && !self[i].nil?
        #puts "Array[#{i.to_s}].to_s=#{self[i].to_s}" if @env.debug? && !self[i].nil?
        self[i]=Command.new({ :input => self[i], :quiet => true }) if(self[i].is_a?(String))
        self[i]=Command.new(self[i]) if(self[i].is_a?(Hash) && !self[i].is_a?(Command))

        if(!value.nil? && value.is_a?(Hash))
          value.each{|k,v|self[i][k]=v}
        end

        if(self[i].is_a?(Command))
          self[i].execute
          @env.out self[i].summary
        end

        i=i+1
      end
    end

    def add command
      self << command if !has_command? command
    end

    def log_debug_info(title)
      if defined?(DEBUG) && self.length > 0
        puts
        puts title
        self.each{|c| puts "  #{c[:input]}" }
        #pp self 
        puts
      end
    end

    def has_command? command
      return true if(command.kind_of?(String) && !include?(command))
      if(command.kind_of?(Command))
        self.each{|c|
          if c.kind_of?(String)
            return true if command[:input] == c
          else
            return true if(c[:input] == command[:input])
          end
        }
      end
      false
    end

    def add_quiet command
      add Command.new({ :input => command, :quiet => true })
    end

    def add_passive command
      add Command.new({ :input => command, :quiet => true, :ignore_failure => true })
    end

    def to_html
      html=Array.new
      html << '<div>'
      self.each{|e|
        html << e.to_html if e.respond_to?(:to_html)
      }
      html << '</div>'
      html.join
    end

end