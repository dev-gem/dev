# frozen_string_literal: true

desc "performs svn update"
task :update do Tasks.execute_task :update; end

class Update < Array
  def update
    add_quiet "svn update" if File.exist?(".svn") && Internet.available?

    # if(Dir.glob('**/packages.config').length > 0)
    Dir.glob("*.sln").each do |sln_file|
      # add_quiet "nuget restore #{sln_file}"
      add_quiet "nuget update #{sln_file}"
    end
    # end
  end
end
