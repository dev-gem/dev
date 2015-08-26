# Copyright 2012-2015 Lou Parslow
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#


Gem::Specification.new do |s|
	s.name			= 'dev'
	s.version		= "2.0.258"
	s.date			= '2015-08-25'
	s.summary		= 'dev'
	s.description	= 'development tasks'
	s.authors		= ["Lou Parslow"]
	s.email			= 'lou.parslow@gmail.com'
	s.homepage		= 'http://rubygems.org/gems/dev'
    s.required_ruby_version = '>= 1.9.3'
    s.executables   = ["dev"]
	s.files         = Dir["LICENSE","README","{lib}/**/*.rb","{test]/**/test_*.rb"]
	s.license       = 'Apache 2.0'
	s.add_runtime_dependency 'rake', '~> 10.1'
    s.add_runtime_dependency 'rspec', '~> 3.0'
end
