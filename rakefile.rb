require 'rake/clean'

CLEAN.include('*.gem','*.html')
CLEAN.include('.yardopts') if File.exists?('.yardopts')
CLOBBER.include('*.gem','lib/dev_*.rb')
build_product= "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

task :build do
	puts ':build'
	Dir.glob('*.gem'){|f|File.delete f}
	puts `gem build dev.gemspec`
	raise 'build failed' if($?.to_i != 0)

	#FileUtils.cp('dev.gemspec','dev.0.0.0.gemspec')
	File.open('dev.0.0.0.gemspec','w'){|f|
		f.write(IO.read('dev.gemspec').gsub(/version\s*=\s*'[\d.]+'/,"version='0.0.0'"))
	}
	File.delete 'dev.0.0.0.gemspec'
end

task :test do
	puts ':test'
	#puts `rspec --format documentation`
	#puts `rspec --profile`
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
	puts ':publish'
	require_relative('./lib/apps/git.rb')
    Git.tag "#{File.dirname(__FILE__)}","#{Gem::Specification.load('dev.gemspec').version.to_s}" if `git branch`.include?('* master') 
	begin
		puts 'gem yank dev 0.0.0'
		puts `gem push dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem`
		FileUtils.rm(" dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem")
	rescue
	end
end

task :show_projects , [:filter] do |t, args| 
	require_relative('./lib/base/projects.rb')
	PROJECTS.show if !args.has_key? :filter
	PROJECTS.show args[:filter] if args.has_key? :filter
end

task :default => [:build,:test,:add,:commit,:publish,:push]