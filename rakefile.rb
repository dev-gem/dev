ENV["DEBUG"] = 'true'
require_relative('./lib/dev.rb')


puts RUBY_PLATFORM
puts "DEBUG=#{ENV['DEBUG']}" if ENV.has_key?('DEBUG')
puts "os: #{Environment.OS}"
puts "msbuild: #{MSBuild.get_vs_version nil}"
CLEAN.include('*.gem','*.html')
CLEAN.include('.yardopts') if File.exists?('.yardopts')
CLEAN.exclude('bin')
CLOBBER.exclude('lib')
CLOBBER.include('*.gem','lib/dev_*.rb')
CLOBBER.exclude('bin')
build_product= "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

task :setup do
	File.open('bin/dev','w'){|f| 
		f.write("#!/usr/bin/env ruby\n") 
		f.write("require 'dev'\n")
		f.write("DEV.execute ARGV\n")
	}
end

task :build do
	Dir.glob('*.gem'){|f|File.delete f}
	puts Command.execute('gem build dev.gemspec').summary
	File.open('dev.0.0.0.gemspec','w'){|f|
		f.write(IO.read('dev.gemspec').gsub(/version\s*=\s*'[\d.]+'/,"version='0.0.0'"))
	}
	puts Command.execute('gem build dev.0.0.0.gemspec').summary
	puts Command.execute('gem uninstall dev --quiet --all -x').summary
	puts Command.execute('gem install dev-0.0.0.gem').summary
	File.delete 'dev.0.0.0.gemspec'
end

task :publish do
	if(Git.user_email.length > 0)
       Git.tag "#{File.dirname(__FILE__)}","#{Gem::Specification.load('dev.gemspec').version.to_s}" if `git branch`.include?('* master') 
	   begin
		puts Command.execute("gem push dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem").summary
		FileUtils.rm(" dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem")
	   rescue
	   end
    end
end
