# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require_relative('../base/environment')

NUGET_FILES = FileList.new('**/*.nuspec')

desc 'performs package commands'
task :package do Tasks.execute_task :package; end

class Package < Array
  def update
    update_nuget if Environment.windows?
  end

  def update_nuget
    puts 'Package scanning for nuget files' if Environment.default.debug?
    NUGET_FILES.each do |nuget_file|
      next if nuget_file.include?('/obj/')

      package_commands = Nuget.get_build_commands nuget_file
      next if package_commands.nil?

      package_commands.each do |c|
        add_passive(c)
      end
    end
  end
end
