# frozen_string_literal: true

desc 'performs a git push'
task :push do Tasks.execute_task :push; end

class Push < Array
  def update
    if !defined?(NO_PUSH) && (File.exist?('.git') && `git config --list`.include?('user.name=')) && (`git branch`.include?('* master') || `git branch`.include?('* develop'))
      add_passive 'git push'
      add_passive 'git push --tags'
    end
  end
end
