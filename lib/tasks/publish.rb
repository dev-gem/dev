puts __FILE__ if defined?(DEBUG)

desc 'performs publish commands'
task :publish do Tasks.execute_task :publish; end

class Publish < Array
	def update

		if(File.exists?('.git') && defined?(VERSION))
			add "<%Git.tag('#{Rake.application.original_dir}','#{VERSION}')%>"
		end

		if(Internet.available?)
			if(File.exists?('.git'))
				if(`git branch`.include?('* master'))
					Dir.glob('*.gemspec').each{|gemspec_file|
						add "gem push #{Gemspec.gemfile(gemspec_file)}" if !Gemspec.published? gemspec_file
					}
				end
			end
			if(File.exists?('.svn'))
				if(`svn info`.include?('/trunk'))
					Dir.glob('*.gemspec').each{|gemspec_file|
						add "gem push #{Gemspec.gemfile(gemspec_file)}" if !Gemspec.published? gemspec_file
					}
				end
			end
		end
		Dir.glob('**/*.{nupkg,msi,gem}').each{|publish_file|
			dest="#{Environment.dev_root}/publish/#{File.basename(publish_file)}"
			FileUtils.mkdir_p("#{Environment.dev_root}/publish") if !File.exists?("#{Environment.dev_root}/publish")
			add "<%FileUtils.cp('#{publish_file}','#{dest}')%>" if(!File.exists?(dest))
		}
	end
end