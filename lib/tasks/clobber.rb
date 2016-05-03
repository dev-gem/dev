puts __FILE__ if defined?(DEBUG)

require 'rake/clean'
# CLOBBER Files
CLOBBER.include('**/*.nupkg')
CLOBBER.include('**/*.gem')

# CLOBBER Folders
CLOBBER.include('bin/**/*')
CLOBBER.include('bin') if File.exists?('bin')
CLOBBER.include('**/bin')
CLOBBER.include('doc') if File.exists?('doc')
CLOBBER.include('obj') if File.exists?('obj')
CLOBBER.include('**/obj')
CLOBBER.include('packages') if File.exists?('packages')
CLOBBER.include('**/.vs')

CLOBBER.include('*.gem')
CLOBBER.include('DTAR_*')
CLOBBER.include('.vs') if File.exists?('.vs')

desc 'performs clobber commands'
task :clobber => [:clean] do Tasks.execute_task :clobber;end
