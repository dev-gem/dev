

desc 'default task'
task :default do
  [:setup,:build,:test,:add,:commit,:publish,:clean,:update].each{|task| 
    Rake::Task[task].invoke 
  }
  project.mark_work_up_to_date if !project.nil?
  puts "[:default] completed in #{TIMER.elapsed_str}" if !Environment.default.colorize?
  if Environment.default.colorize?
    require 'ansi/code'
    puts ANSI.white + ANSI.bold + ":default"  + " completed in " + ANSI.yellow + "#{TIMER.elapsed_str}" + ANSI.reset
  end
end