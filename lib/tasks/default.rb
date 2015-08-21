puts __FILE__ if defined?(DEBUG)

require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/projects.rb')
require_relative('../base/timer.rb')

RAKE_DEFAULT_EXISTS=File.exists?('rake.default')



if(!defined?(NO_DEFAULT_TASK)) 
  desc 'perform project commands to push gem development'
  task :default do
    if(defined?(DEFAULT_TASKS))
      DEFAULT_TASKS.each{|task| Rake::Task[task].invoke}
    else
    	if(File.exists?('.git'))
        CLEAN.exclude('rake.default')
        Rake::Task["clean"].invoke
        Rake::Task["clean"].reenable
        CLEAN.include('rake.default')
        puts `git add -A` if(File.exists?('.gitignore'))
        if(Git.has_changes?)
          puts 'Git changes detected.'
          puts `git status`
    		  [:setup,:build,:test,:add,:commit,:publish,:clean,:push,:pull].each{|task| Rake::Task[task].invoke}
        elsif !RAKE_DEFAULT_EXISTS
          puts 'rake.default does not exist.'
          [:setup,:build,:test,:add,:commit,:publish,:clean,:push,:pull].each{|task| Rake::Task[task].invoke}
        else
          puts 'no changes detected.'
        end
    	else
  	  	if(File.exists?('.svn'))
          if(Svn.has_changes? || !File.exists?('rake.default'))
  	  		  [:setup,:build,:test,:add,:commit,:publish,:clean,:update].each{|task| Rake::Task[task].invoke}
          else
            puts 'no changes detected.'
          end
  	  	else
          [:setup,:build,:test,:publish].each{|task| Rake::Task[task].invoke}
  	  	end
  	 end
    end
    
    puts "[:default] completed in #{TIMER.elapsed_str}"
    File.open('rake.default','w'){|f|f.puts "[:default] completed in #{TIMER.elapsed_str}"}
  end # :default
end