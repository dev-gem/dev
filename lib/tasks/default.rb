require 'rake'
require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/dir.rb')
require_relative('../base/environment.rb')
require_relative('../base/projects.rb')
require_relative('../base/project.rb')
require_relative('../base/timer.rb')

puts "defining DEFAULT TASK" if Environment.default.debug?
puts "working? = #{Environment.default.working?}" if Environment.default.debug?
logfile=''
#projects=Projects.new
#project=projects.get_current
#if(!project.nil?)
#  logfile=project.get_logfile ['work','default','OK']
#  if(File.exists?(logfile))
#    puts "DEFAULT: logfile #{logfile} exists" if Environment.default.debug?
#    if(File.mtime(logfile) > Dir.get_latest_mtime(Rake.application.original_dir))
#      NO_CHANGES=true
#    else
#      puts "DEFAULT: deleting #{logfile}" if Environment.default.debug?
#      File.delete logfile
#    end
#  end
#else
#  puts 'DEFAULT: current project is nil' if Environment.default.debug?
#end

if(!defined?(NO_DEFAULT_TASK)) 
  desc 'default task'
  task :default do
    if(defined?(DEFAULT_TASKS))
      DEFAULT_TASKS.each{|task| Rake::Task[task].invoke}
    else
      if defined? NO_CHANGES
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

    puts "DEFAULT: writing #{logfile}" if Environment.default.debug?
    File.open(logfile,'w'){|f|f.write(' ')} if(logfile.length > 0)
  end # :default
end