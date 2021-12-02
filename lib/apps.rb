# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

%w[git msbuild nuget svn wix xcodebuild zip].each { |name| require_relative("apps/#{name}.rb") }
