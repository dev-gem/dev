# frozen_string_literal: true

# rspec spec/ --profile
# rspec spec/ --profile 2
# test fork/pull request
# DEBUG=true
require_relative('./lib/dev')
# VSCode

CLEAN.include('*.gem', '*.html')
CLEAN.include('.yardopts') if File.exist?('.yardopts')
CLEAN.exclude('bin')
CLOBBER.exclude('lib')
CLOBBER.include('*.gem', 'lib/dev_*.rb')
CLOBBER.exclude('bin')
build_product = "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

task :setup do
  File.open('bin/dev', 'w') do |f|
    f.write("#!/usr/bin/env ruby\n")
    f.write("require 'dev'\n")
    f.write("DEV.execute ARGV\n")
  end
end

task :build do
  Dir.glob('*.gem') { |f| File.delete f }
  puts Command.execute('gem build dev.gemspec').summary
  File.open('dev.0.0.0.gemspec', 'w') do |f|
    f.write(IO.read('dev.gemspec').gsub(/version\s*=\s*'[\d.]+'/, "version='0.0.0'"))
  end
  puts Command.execute('gem build dev.0.0.0.gemspec').summary
  puts Command.execute('gem uninstall dev --quiet --all -x').summary
  puts Command.execute('gem install dev-0.0.0.gem').summary
  File.delete 'dev.0.0.0.gemspec'
end

task :publish do
  if Git.user_email.length.positive?
    if `git branch`.include?('* master')
      Git.tag File.dirname(__FILE__).to_s,
              Gem::Specification.load('dev.gemspec').version.to_s
    end
    begin
      puts Command.execute("gem push dev-#{Gem::Specification.load('dev.gemspec').version}.gem").summary
      FileUtils.rm(" dev-#{Gem::Specification.load('dev.gemspec').version}.gem")
    rescue StandardError
    end
  end
end

task :msbuild do
  puts MSBUILD
  puts MSBUILD[:vs16]
  puts MSBuild.get_version(:vs16) if MSBuild.has_version?(:vs16)
end
