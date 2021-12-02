# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

desc 'commits source files to git or subversion'
if File.exist?('git')
end
task commit: [:add] do Tasks.execute_task :commit; end

class Commit < Array
  def update
    message = ''
    message = IO.read('commit.message').strip if File.exist?('commit.message')

    if File.exist?('.git') && `git config --list`.include?('user.name=') && Git.user_email.length.positive? && (!`git status`.include?('nothing to commit') &&
         !`git status`.include?('untracked files present') &&
         !`git status`.include?('no changes add to commit'))
      if message.length.zero?
        if defined?(REQUIRE_COMMIT_MESSAGE)
          Commit.reset_commit_message
          raise 'commit.message required to perform commit'
        else
          add_passive "git commit -m'all'"
        end
      else
        add_quiet 'git commit -a -v --file commit.message'
        add_quiet '<%Commit.reset_commit_message%>'
      end
    end
    if File.exist?('.svn')
      if message.length.zero?
        if defined?(REQUIRE_COMMIT_MESSAGE)
          Commit.reset_commit_message
          raise 'commit.message required to perform commit'
        else
          add_quiet 'svn commit -m"commit all"'
        end
      else
        add_quiet 'svn commit --file commit.message'
        add_quiet '<%Commit.reset_commit_message%>'
      end
    end

    log_debug_info('Commit') if defined?(DEBUG)
  end

  def self.reset_commit_message
    File.open('commit.message', 'w') { |f| f.write('') }
  end
end
