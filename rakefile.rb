require 'rake/clean'

CLEAN.include('*.gem','rake.default')
CLOBBER.include('*.gem','lib/dev_*.rb')
build_product= "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

task :build do
	Dir.glob('*.gem'){|f|File.delete f}
	puts `gem build dev.gemspec`
	raise 'build failed' if($?.to_i != 0)
end

task :test do
	#puts `rspec --format documentation`
	puts `rspec`
	raise 'rspec failed' if($?.to_i != 0)
end

task :add do
	puts `git add -A`
end 

task :commit =>[:add] do
	puts `git commit -m'all'`
end

task :pull do
	puts `git pull` if `git branch`.include?('* master')
end

task :push do
	puts `git push`  if `git branch`.include?('* master')
end 

task :publish do
	require_relative('./lib/apps/git.rb')
    Git.tag "#{File.dirname(__FILE__)}","#{Gem::Specification.load('dev.gemspec').version.to_s}"
	  begin
		puts `gem push dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem`
	  rescue
	  end
end

task :show_projects , [:filter] do |t, args| 
	require_relative('./lib/base/projects.rb')
	PROJECTS.show if !args.has_key? :filter
	PROJECTS.show args[:filter] if args.has_key? :filter
end

task :default => [:build,:test,:add,:commit,:publish,:push] do
	File.open('rake.default','w'){|f|f.puts 'a'}
end