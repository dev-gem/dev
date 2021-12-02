# frozen_string_literal: true

require 'rake'
require_relative('info')
require_relative('../base/array')
require_relative('../base/dir')
require_relative('../base/environment')
require_relative('../base/projects')
require_relative('../base/project')
require_relative('../base/timer')

puts 'defining DEFAULT TASK' if Environment.default.debug?

work_up_to_date = false
if defined?(DEV)
  puts 'DEFAULT: DEV is defined' if DEV.env.debug?
  project = DEV.projects.current
  puts 'project is nil' if DEV.env.debug? && project.nil?
  unless project.nil?
    if project.work_up_to_date?
      puts 'project work is up to date' if DEV.env.debug?
      work_up_to_date = true
    elsif DEV.env.debug?
      puts 'project work is NOT up to date'
    end
  end
end

if defined?(NO_DEFAULT_TASK)
  puts 'NO_DEFAULT_TASK is defined' if Environment.default.debug?
else
  default_tasks = nil
  default_tasks = DEFAULT_TASKS if defined? DEFAULT_TASKS
  if default_tasks.nil?
    if work_up_to_date
      default_tasks = []
    elsif File.exist?('.git')
      if defined?(NO_AUTO_COMMIT)
        default_tasks = %i[setup build test package publish clean]
      else
        puts ':add,:commit,:push,:pull tasks are part of :default, to opt-out, define NO_AUTO_COMMIT'
        default_tasks = %i[setup build test add commit package publish clean push pull]
      end
    elsif File.exist?('.svn')
      default_tasks = %i[setup build test add commit publish clean]
    else
      default_tasks = %i[setup build test package publish]
    end
  end

  puts "default_tasks=#{default_tasks}" if Environment.default.debug?
  desc "default task #{default_tasks}"
  task :default do
    default_tasks.each do |task|
      Rake::Task[task].invoke
    end
    project&.mark_work_up_to_date
    puts "[:default] completed in #{TIMER.elapsed_str}" unless Environment.default.colorize?
    if Environment.default.colorize?
      require 'ansi/code'
      puts "#{ANSI.white}#{ANSI.bold}:default completed in #{ANSI.yellow}#{TIMER.elapsed_str}#{ANSI.reset}"
    end
  end
end
