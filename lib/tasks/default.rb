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
  #puts "working? = #{DEV.env.working?}" if DEV.env.debug?
  #puts "current project is nil" if DEV.env.debug? && DEV.projects.current.nil?
  #puts "current project #{DEV.projects.current.fullname}" if DEV.env.debug? && !DEV.projects.current.nil?
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
  #puts "no_changes? = #{DEV.env.no_changes?}" if DEV.env.debug?
end
if(defined?(NO_DEFAULT_TASK))
  puts "NO_DEFAULT_TASK is defined" if Environment.default.debug?
elsif(work_up_to_date)
  puts "work_up_to_date is true" if Environment.default.debug?
  desc 'default task'
  task :default do
    puts '   no changes'
  end
else
#if(!defined?(NO_DEFAULT_TASK)) 
  puts "defining default task" if Environment.default.debug?
  desc 'default task'
  task :default do
    if(defined?(DEFAULT_TASKS))
      DEFAULT_TASKS.each{|task| Rake::Task[task].invoke}
      project.mark_work_up_to_date if !project.nil?
    else
      if defined? WRK_UP_TO_DATE
        puts '   no changes'
      else
    	  if(File.exists?('.git'))
    		  [:setup,:build,:test,:add,:commit,:publish,:clean,:push,:pull].each{|task| Rake::Task[task].invoke }
    	  else
  	  	  if(File.exists?('.svn'))
  	  		  [:setup,:build,:test,:add,:commit,:publish,:clean,:update].each{|task| Rake::Task[task].invoke }
  	  	  else
            [:setup,:build,:test,:publish].each{|task| Rake::Task[task].invoke}
  	  	  end
        end
        project.mark_work_up_to_date if !project.nil?
  	  end
    end
    
    puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
    if Environment.default.colorize?
      require 'ansi/code'
      puts ANSI.white + ANSI.bold + ":default"  + " completed in " + ANSI.yellow + "#{TIMER.elapsed_str}" + ANSI.reset
    end
  end # :default
end