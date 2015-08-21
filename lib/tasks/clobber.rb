puts __FILE__ if defined?(DEBUG)

require 'rake/clean'
# CLOBBER Files
CLOBBER.include('**/*.nupkg')
CLOBBER.include('**/*.gem')

# CLOBBER Folders
CLOBBER.include('bin') if File.exists?('bin')
CLOBBER.include('doc') if File.exists?('doc')

CLOBBER.include('*.gem')
CLOBBER.include('bin','obj','packages')

desc 'performs clobber commands'
task :clobber => [:clean] do Tasks.execute_task :clobber;end
