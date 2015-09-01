require 'rake'
require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/dir.rb')
require_relative('../base/environment.rb')
require_relative('../base/projects.rb')
require_relative('../base/project.rb')
require_relative('../base/timer.rb')

logfile=''
projects=Projects.new
project=projects.get_current
if(!project.nil?)
  logfile=project.get_logfile ['work','default','OK']
  if(File.exists?(logfile))
    if(File.mtime(logfile) > Dir.get_latest_mtime(Rake.application.original_dir))
      NO_CHANGES=true
    else
      File.delete logfile
    end
  end
end

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
    		  [:setup,:build,:test,:add,:commit,:publish,:clean,:push,:pull].each{|task| 
            Rake::Task[task].invoke
            File.open(logfile,'w'){|f|f.write(' ')} if(logfile.length > 0)
          }
    	  else
  	  	  if(File.exists?('.svn'))
  	  		  [:setup,:build,:test,:add,:commit,:publish,:clean,:update].each{|task| 
              Rake::Task[task].invoke
              File.open(logfile,'w'){|f|f.write(' ')} if(logfile.length > 0)
            }
  	  	  else
            [:setup,:build,:test,:publish].each{|task| 
              Rake::Task[task].invoke
              File.open(logfile,'w'){|f|f.write(' ')} if(logfile.length > 0)
            }
  	  	  end
        end
  	  end
    end
    
    puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
    if Environment.default.colorize?
      require 'ansi/code'
      puts ANSI.white + ANSI.bold + ":default"  + " completed in " + ANSI.yellow + "#{TIMER.elapsed_str}" + ANSI.reset
    end
  end # :default
end