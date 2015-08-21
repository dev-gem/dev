puts __FILE__ if defined?(DEBUG)

class Hash
	def execute value=nil
	  self.each{|k,v|
      v.update if v.respond_to?(:update)
      if(v.is_a?(Array) && v.length==0)
        self.delete k 
      else
	  	  v.execute(value) if v.respond_to?(:execute)
      end
	  }
    end
	def to_html
      [
      	'<div>',
        map { |k, v| ["<br/><div><strong>#{k}</strong>", v.respond_to?(:to_html) ? v.to_html : "<span>#{v}</span></div><br/>"] },
        '</div>'
      ].join
    end
end