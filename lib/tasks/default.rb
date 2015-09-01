require 'rake'
require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/dir.rb')
require_relative('../base/environment.rb')
require_relative('../base/projects.rb')
require_relative('../base/project.rb')
require_relative('../base/timer.rb')

puts "defining DEFAULT TASK" if Environment.default.debug?

if(defined?(DEV))
  puts "DEFAULT: DEV is defined" if DEV.env.debug?
  #puts "working? = #{DEV.env.working?}" if DEV.env.debug?
  #puts "current project is nil" if DEV.env.debug? && DEV.projects.current.nil?
  #puts "current project #{DEV.projects.current.fullname}" if DEV.env.debug? && !DEV.projects.current.nil?
  project=DEV.projects.current
  puts "project is nil" if DEV.env.debug? && project.nil?
  if(!project.nil? && project.work_up_to_date?)
    puts "project work is up to date " if DEV.env.debug?
    WRK_UP_TO_DATE=true
  end
  #puts "no_changes? = #{DEV.env.no_changes?}" if DEV.env.debug?
end

if(!defined?(NO_DEFAULT_TASK)) 
  desc 'default task'
  task :default do
    if(defined?(DEFAULT_TASKS))
      DEFAULT_TASKS.each{|task| Rake::Task[task].invoke}
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
  	  end
    end
    
    puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
    if Environment.default.colorize?
      require 'ansi/code'
      puts ANSI.white + ANSI.bold + ":default"  + " completed in " + ANSI.yellow + "#{TIMER.elapsed_str}" + ANSI.reset
    end

    project.mark_work_up_to_date if !project.nil?
  end # :default
end