# frozen_string_literal: true

require_relative '../base/array'
desc 'performs publish commands'
task :publish do Tasks.execute_task :publish; end

class Publish < Array
  def update
    add_quiet "<%Git.tag('#{Rake.application.original_dir}','#{VERSION}')%>" if File.exist?('.git') && defined?(VERSION)

    if Internet.available?
      if File.exist?('.git') && `git branch`.include?('* master')
        Dir.glob('*.gemspec').each do |gemspec_file|
          add_passive "gem push #{Gemspec.gemfile(gemspec_file)}" unless Gemspec.published? gemspec_file
        end
      end
      if File.exist?('.svn') && `svn info`.include?('/trunk')
        Dir.glob('*.gemspec').each do |gemspec_file|
          add_quiet "gem push #{Gemspec.gemfile(gemspec_file)}" unless Gemspec.published? gemspec_file
        end
      end
    end
  end
end
