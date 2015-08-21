require_relative '../lib/base/projects.rb'

describe Projects do
	def show 
		self.each{|k,v|
			puts k
		}
	end
end