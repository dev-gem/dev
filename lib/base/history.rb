puts __FILE__ if defined?(DEBUG)

class History
	attr_accessor :dev

	def initialize dev=nil
		@dev=dev
		@dev=Dev.new if @dev.nil?
	end
	
	def get_work_command value
		nil
	end
end