puts __FILE__ if defined?(DEBUG)

require 'rake/clean'
# Clean Files
CLEAN.include('**/*.{sdf,sud,ncb,cache,user,wixobj,wixpdb}')
CLEAN.include('rake.default')

# Clean Folders
CLEAN.include('obj') if File.exists?('obj')
CLEAN.include('tmp') if File.exists?('tmp')
