# frozen_string_literal: true

if defined?(DEBUG)
  puts DELIMITER
  puts __FILE__
end

desc "adds source files to git or subversion"
task :add do Tasks.execute_task :add; end

class Add < Array
  def update
    if File.exist?(".git") && File.exist?(".gitignore")
      add_quiet "git add --all"
    elsif defined?(SOURCE)
      if File.exist?(".svn")
        #---
        list_output = `svn list -R`
        status_output = `svn status`
        status_output = status_output.gsub(/\\/, "/")
        #---
        SOURCE.each do |f|
          if File.exist?(f) && File.file?(f) && !list_output.include?(f) && (m = status_output.match(/^(?<action>.)\s+(?<file>#{f})$/i)) && (m[:file] == f && m[:action] == "?")
            add_quiet "svn add \"#{f}\" --parents"
          end
        end
      end
      if File.exist?(".git")
        SOURCE.each do |f|
          if File.exist?(f) && File.file?(f)
            status = Command.output("git status #{f} --short")
            add_quiet "git add #{f} -v" if status.include?("??") || status.include?(" M ")
          end
        end
      end
    end

    log_debug_info("Add") if defined?(DEBUG)
  end
end
