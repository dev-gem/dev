if defined?(DEBUG)
    puts DELIMITER
    puts __FILE__
end

require_relative('apps.rb')

require 'json'
require 'rake/clean'
require 'pp'

Dir.glob("#{File.dirname(__FILE__)}/tasks/*.rb").each{|rb| 
  require(rb) if !rb.include?('default')
}
class Commands < Hash
	attr_accessor :env
	def initialize env=nil,directory=Rake.application.original_dir
		@env=env
		@env=Environment.new() if @env.nil?
		Dir.chdir(directory) do
		  self[:pull]=Pull.new
		  self[:update]=Update.new
		  self[:setup]=Setup.new
		  self[:build]=Build.new
		  self[:test]=Test.new
		  self[:analyze]=Analyze.new
		  self[:doc]=Doc.new
		  self[:package]=Package.new
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
					puts "  #{c[:input]}" if(!c.kind_of?(Hash))
				}
			end
		}
	end
end

COMMANDS=Commands.new
MSBUILD=MSBuild.new
