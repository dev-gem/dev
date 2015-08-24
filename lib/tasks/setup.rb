puts __FILE__ if defined?(DEBUG)

desc 'performs setup commands'
task :setup do Tasks.execute_task :setup;end

#
# use the SVN_EXPORTS hash to define svn exports destined for DEV_ROOT/dep
#
# SVN_EXPORT={ 'System.Data.SQLite/1.0.93.0' => 'https://third-party.googlecode.com/svn/trunk/System.Data.SQLite/1.0.93.0' }
#
class Setup < Array
	def update
		add 'bundle install' if(File.exists?('Gemfile'))

		['bin','data','log','make','publish'].each{|dir|
			add "<%FileUtils.mkdir('#{Environment.dev_root}/#{dir}')%>" if !File.exists? "#{Environment.dev_root}/#{dir}"
		}
		
		Dir.glob('*.gemspec').each{|gemspec_file|
			add "<%Gemspec.update('#{gemspec_file}')%>"
		}

		if(Dir.glob('**/packages.config').length > 0)
			Dir.glob('*.sln').each{|sln_file|
				add "nuget restore #{sln_file}"
			}
		end

		if(defined?(SVN_EXPORTS))
			SVN_EXPORTS.each{|k,v|
				if(!File.exists?("#{Command.dev_root}/dep/#{k}"))
			      FileUtils.mkdir_p(File.dirname("#{Command.dev_root}/dep/#{k}")) if !File.exists?("#{Command.dev_root}/dep/#{k}")
				  dest="#{Command.dev_root}/dep/#{k}"
			      add "svn export #{v} #{Command.dev_root}/dep/#{k}" if !dest.include?("@")
				  add "svn export #{v} #{Command.dev_root}/dep/#{k}@" if dest.include?("@")
		        end
			}
		end

		if(defined?(GIT_EXPORTS))
			GIT_EXPORTS.each{|k,v|
				directory = "#{Command.dev_root}/dep/#{k}"
				if(!File.exists?(directory))
					if(v.include?('@'))
						puts `git clone #{v.split('@')[0]} #{directory}`
						Dir.chdir(directory) do
							puts `git reset --hard #{v.split('@')[1]}`
						end
					else
						add "git clone #{v} #{directory}"
					end
				end
			}
		end

		if(defined?(VERSION))
			Dir.glob('*.nuspec').each{|nuspec|
				current_version=IO.read(nuspec).scan(/<version>[\d.]+<\/version>/)[0]
				puts "#{nuspec} current version=#{current_version}" if defined?(DEBUG)
				if(current_version.include?('<version>'))
					target_version="<version>#{VERSION}</version>"
					if(current_version != target_version)
						add "<%Text.replace_in_file('#{nuspec}','#{current_version}','#{target_version}')%>"
					end
				end
			}
			Dir.glob('**/AssemblyInfo.cs').each{|assemblyInfo|
				current_version=IO.read(assemblyInfo).scan(/Version\(\"[\d.]+\"\)/)[0]
				puts "#{assemblyInfo} current version=#{current_version}" if defined?(DEBUG)
				if(current_version.include?('Version('))
					target_version="Version(\"#{VERSION}\")"
					if(current_version != target_version)
						add "<%Text.replace_in_file('#{assemblyInfo}','#{current_version}','#{target_version}')%>"
					end
				end
			}
		end
	end
end