# frozen_string_literal: true

desc "performs a git pull"
task :pull do Tasks.execute_task :pull; end

class Pull < Array
  def update
    if !defined?(NO_PULL) && File.exist?(".git") && `git config --list`.include?("user.name=") && (Git.branch == "master")
      add_passive("git pull")
    end
  end
end
