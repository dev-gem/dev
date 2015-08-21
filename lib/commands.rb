puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake/clean'

Dir.glob("#{File.dirname(__FILE__)}/tasks/*.rb").each{|rb| 
  require(rb)
}
class Commands < Hash

	def initialize directory=Dir.pwd
		Dir.chdir(directory) do
		  self[:pull]=Pull.new
		  self[:update]=Update.new
		  self[:setup]=Setup.new
		  self[:build]=Build.new
		  self[:test]=Test.new
		  self[:analyze]=Analyze.new
		  self[:doc]=Doc.new
		  self[:publish]=Publish.new
		  self[:add]=Add.new
		  self[:commit]=Commit.new
		  self[:push]=Push.new
	    end
	end

	def info
		puts "Commands"
		self.each{|k,v|
			v.update if v.respond_to? 'update'
			if v.length > 0
				puts " #{k}"
				v.each{|c|
					puts "  #{c}" if(!c.kind_of?(Hash))
				}
			end
		}
	end
end

COMMANDS=Commands.new
MSBUILD=MSBuild.new
