puts __FILE__ if defined?(DEBUG)
require_relative '../base/array.rb'
desc 'performs publish commands'
task :publish do Tasks.execute_task :publish; end

class Publish < Array

	def update
		if(File.exists?('.git') && defined?(VERSION))
			add_quiet "<%Git.tag('#{Rake.application.original_dir}','#{VERSION}')%>"
		end

		if(Internet.available?)
			if(File.exists?('.git'))
				if(`git branch`.include?('* master'))
					Dir.glob('*.gemspec').each{|gemspec_file|
						add_passive "gem push #{Gemspec.gemfile(gemspec_file)}" if !Gemspec.published? gemspec_file
					}
				end
			end
			if(File.exists?('.svn'))
				if(`svn info`.include?('/trunk'))
					Dir.glob('*.gemspec').each{|gemspec_file|
						add_quiet "gem push #{Gemspec.gemfile(gemspec_file)}" if !Gemspec.published? gemspec_file
					}
				end
			end
		end

		Dir.glob("#{Rake.application.original_dir}/**/*.{nupkg,msi,gem}").each{|publish_file|
			dest="#{Environment.default.publish_dir}/#{File.basename(publish_file)}"
			add_quiet "<%FileUtils.cp('#{publish_file}','#{dest}')%>" if(!File.exists?(dest))
		}
	end
end