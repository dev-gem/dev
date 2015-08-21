puts __FILE__ if defined?(DEBUG)

['git','msbuild','nuget','svn','wix'].each{|name| require_relative("apps/#{name}.rb")}