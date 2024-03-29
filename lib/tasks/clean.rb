# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require "rake/clean"
# Clean Files
CLEAN.include("**/*.{sdf,sud,ncb,cache,user,wixobj,wixpdb,nupkg}")

# Clean Folders
CLEAN.include("obj") if File.exist?("obj")
CLEAN.include("tmp") if File.exist?("tmp")
