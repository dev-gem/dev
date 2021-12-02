# frozen_string_literal: true

desc 'performs documentation commands'
task :doc do Tasks.execute_task :doc; end

class Doc < Array
  def update
    if Command.exit_code('yard --version') && (File.exist?('README.md') && File.exist?('LICENSE'))
      add_quiet 'yard doc - LICENSE'
    end
  end
end
