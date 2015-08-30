#require 'rake/clean'
require_relative('./lib/dev.rb')

puts "DEBUG=#{ENV['DEBUG']}" if ENV.has_key?('DEBUG')
CLEAN.include('*.gem','*.html')
CLEAN.include('.yardopts') if File.exists?('.yardopts')
CLOBBER.include('*.gem','lib/dev_*.rb')
build_product= "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

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
    Git.tag "#{File.dirname(__FILE__)}","#{Gem::Specification.load('dev.gemspec').version.to_s}" if `git branch`.include?('* master') 
	begin
		puts Command.execute("gem push dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem").summary
		FileUtils.rm(" dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem")
	rescue
	end
end

task :show_projects , [:filter] do |t, args| 
	require_relative('./lib/base/projects.rb')
	PROJECTS.show if !args.has_key? :filter
	PROJECTS.show args[:filter] if args.has_key? :filter
end

task :show_colors do
	require 'ansi/code'
	puts ANSI.black "==black" + ANSI.reset
	puts ANSI.black + ANSI.bright + "==light black"  + ANSI.reset
	puts ANSI.red "==red"  + ANSI.reset
	puts ANSI.red + ANSI.bright + "==light red"  + ANSI.reset
	puts ANSI.green "==green"  + ANSI.reset
	puts ANSI.green + ANSI.bright + "==light green"  + ANSI.reset
	puts ANSI.green + ANSI.faint + "==faint green"  + ANSI.reset
	puts ANSI.green + ANSI.dark + "==dark green"  + ANSI.reset
	puts ANSI.yellow "==yellow"  + ANSI.reset
	puts ANSI.yellow + ANSI.bright + "==light yellow"  + ANSI.reset
	puts ANSI.blue "==blue"  + ANSI.reset
	puts ANSI.blue + ANSI.bright + "==light blue"  + ANSI.reset
	puts ANSI.magenta "==magenta"  + ANSI.reset
	puts ANSI.magenta + ANSI.bright + "==light magenta"  + ANSI.reset
	puts ANSI.cyan "==cyan"  + ANSI.reset
	puts ANSI.cyan + ANSI.bright + "==light cyan"  + ANSI.reset
	puts ANSI.white "==white"  + ANSI.reset
	puts ANSI.white + ANSI.bright + "==light white"  + ANSI.reset
	puts ANSI.reset
end

task :default => [:setup,:build,:test,:add,:commit,:publish,:push]