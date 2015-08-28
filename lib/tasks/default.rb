puts __FILE__ if defined?(DEBUG)

require_relative('info.rb')
require_relative('../base/array.rb')
require_relative('../base/projects.rb')
require_relative('../base/timer.rb')

if(!defined?(NO_DEFAULT_TASK)) 
  desc 'perform project commands to push gem development'
  task :default do
    if(defined?(DEFAULT_TASKS))
      DEFAULT_TASKS.each{|task| Rake::Task[task].invoke}
    else
    	if(File.exists?('.git'))
    		[:setup,:build,:test,:add,:commit,:publish,:clean,:push,:pull].each{|task| Rake::Task[task].invoke}
    	else
  	  	if(File.exists?('.svn'))
  	  		[:setup,:build,:test,:add,:commit,:publish,:clean,:update].each{|task| Rake::Task[task].invoke}
  	  	else
          [:setup,:build,:test,:publish].each{|task| Rake::Task[task].invoke}
  	  	end
  	 end
    end
    
    puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
    if @env.colorize?
      require 'ansi/code'
      puts "[" + ANSI.blue + ANSI.bright + ":default" + ANSI.reset + "] completed in #{TIMER.elapsed_str}" if @env.colorize?
    end

  end # :default
end