require 'rake'
require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/dir.rb')
require_relative('../base/environment.rb')
require_relative('../base/projects.rb')
require_relative('../base/project.rb')
require_relative('../base/timer.rb')

puts "defining DEFAULT TASK" if Environment.default.debug?

work_up_to_date=false
if(defined?(DEV))
  puts "DEFAULT: DEV is defined" if DEV.env.debug?
  project=DEV.projects.current
  puts "project is nil" if DEV.env.debug? && project.nil?
  if(!project.nil?)
    if(project.work_up_to_date?)
      puts "project work is up to date" if DEV.env.debug?
      work_up_to_date=true
    else
      puts "project work is NOT up to date" if DEV.env.debug?
    end
  end
end

if(defined?(NO_DEFAULT_TASK))
  puts "NO_DEFAULT_TASK is defined" if Environment.default.debug?
else
  default_tasks=nil
  default_tasks=DEFAULT_TASKS if defined? DEFAULT_TASKS
  if(default_tasks.nil?)
    if(work_up_to_date)
      default_tasks=[]
    elsif(File.exists?('.git'))
      default_tasks=[:setup,:build,:test,:add,:commit,:package,:publish,:clean,:push,:pull]
    elsif File.exists?('.svn')
      default_tasks=[:setup,:build,:test,:add,:commit,:publish,:clean,:update]
    else
      default_tasks=[:setup,:build,:test,:package,:publish]
    end
  end

  puts "default_tasks=#{default_tasks}" if Environment.default.debug?
  desc "default task #{default_tasks.to_s}"
  task :default do
    default_tasks.each{|task| 
      Rake::Task[task].invoke 
    }
    project.mark_work_up_to_date if !project.nil?
    puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
    if Environment.default.colorize?
      require 'ansi/code'
      puts ANSI.white + ANSI.bold + ":default"  + " completed in " + ANSI.yellow + "#{TIMER.elapsed_str}" + ANSI.reset
    end
  end
end