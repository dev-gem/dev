puts __FILE__ if defined?(DEBUG)

class Array
    attr_accessor :env
    def intialize env=nil
      @env=env
      @env=Environment.enw if @env.nil?
    end

    def execute value=nil
      i=0
      while i < self.length
        self[i]=Command.new(self[i]) if(self[i].is_a?(String))
        self[i]=Command.new(self[i]) if(self[i].is_a?(Hash) && !self[i].is_a?(Command))

        if(!value.nil? && value.is_a?(Hash))
          value.each{|k,v|self[i][k]=v}
        end

        self[i].execute if(self[i].is_a?(Command))
        i=i+1
      end
    end

    def add command
      self << command if(!include?(command))
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