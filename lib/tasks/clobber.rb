# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require 'rake/clean'
# CLOBBER Files
CLOBBER.include('**/*.nupkg')
CLOBBER.include('**/*.gem')
CLOBBER.include('**/*.msi')

# CLOBBER Folders
CLOBBER.include('bin/**/*')
CLOBBER.include('bin') if File.exist?('bin')
CLOBBER.include('**/bin')
CLOBBER.include('doc') if File.exist?('doc')
CLOBBER.include('obj') if File.exist?('obj')
CLOBBER.include('**/obj')
CLOBBER.include('lib') if File.exist?('lib')
CLOBBER.include('packages') if File.exist?('packages')
CLOBBER.include('**/.vs')

CLOBBER.include('*.gem')
CLOBBER.include('DTAR_*')
CLOBBER.include('.vs') if File.exist?('.vs')

desc 'performs clobber commands'
task clobber: [:clean] do Tasks.execute_task :clobber; end
