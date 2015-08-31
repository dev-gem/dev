desc 'performs setup commands'
task :setup do Tasks.execute_task :setup;end

#
# use the SVN_EXPORTS hash to define svn exports destined for DEV_ROOT/dep
#
# SVN_EXPORT={ 'System.Data.SQLite/1.0.93.0' => 'https://third-party.googlecode.com/svn/trunk/System.Data.SQLite/1.0.93.0' }
#
class Setup < Array

	def initialize value=nil
		env=value if value.kind_of? Environment
	end

	def update
		env=Environment.new if env.nil?

		add_quiet 'bundle install' if File.exists? 'Gemfile'
		#add Command.new( { :input => 'bundle install', :quiet => true}) if(File.exists?('Gemfile'))

		#['bin','data','log','make','publish','test'].each{|dir|
		#	add "<%FileUtils.mkdir('#{Environment.default.devroot}/#{dir}')%>" if !File.exists? "#{Environment.dev_root}/#{dir}"
		#}
		
		Dir.glob('*.gemspec').each{|gemspec_file|
			add_quiet "<%Gemspec.update('#{gemspec_file}')%>"
			#add Command.new( { :input => "<%Gemspec.update('#{gemspec_file}')%>", :quiet => true} )
		}

		if(Dir.glob('**/packages.config').length > 0)
			Dir.glob('*.sln').each{|sln_file|
				add "nuget restore #{sln_file}"
			}
		end

		puts 'Setup checking SVN_EXPORTS...' if env.debug?
		if(defined?(SVN_EXPORTS))
			SVN_EXPORTS.each{|k,v|
				dest="#{Command.dev_root}/dep/#{k}"
				if(!File.exists?(dest))
			      FileUtils.mkdir_p(File.dirname(dest)) if !File.exists?(File.dirname(dest))
			      add "svn export #{v} #{dest}" if !dest.include?("@")
				  add "svn export #{v} #{dest}@" if dest.include?("@")
				else
					puts "#{Command.dev_root}/dep/#{k} exists." if env.debug?
		        end
			}
		else
			puts 'SVN_EXPORTS is not defined' if env.debug?
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
						add_quiet "git clone #{v} #{directory}"
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
			Dir.glob('**/*.wxs').each{|wxs|
				current_version=IO.read(wxs).scan(/Version=\"([\d.]+)\"/)[0][0]
				puts "#{wxs} current version=#{current_version}" if defined?(DEBUG)
				if(current_version.include?('Version='))
					target_version="Version=\"#{VERSION}\")="
					if(current_version != target_version)
						add "<%Text.replace_in_file('#{wxs}','#{current_version}','#{target_version}')%>"
						add "<%Text.replace_in_file('Value=\"#{current_version}\"','Value=\"#{target_version}\"')%>"
					end
				end
			}
		end
	end
end