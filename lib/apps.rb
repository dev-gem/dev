puts __FILE__ if defined?(DEBUG)

['git','msbuild','nuget','svn','wix','xcodebuild','zip'].each{|name| require_relative("apps/#{name}.rb")}