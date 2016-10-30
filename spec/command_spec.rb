require_relative '../lib/base/command.rb'
require 'json'
require 'fileutils'

describe Command do
  it "should be able to execute ruby --version command" do
    cmd=Command.new({ :input => 'ruby --version', :quiet => true})
    # Timeout
    expect(cmd[:timeout]).to eq(0)
    cmd[:timeout]=3000
    expect(cmd[:timeout]).to eq(3000)

    # Directory
    expect(cmd[:directory]).to eq("")
    cmd[:directory] = File.dirname(__FILE__)
    expect(cmd[:directory]).to eq(File.dirname(__FILE__))

    # ExitCode
    expect(cmd[:exit_code]).to eq(0)
    cmd[:exit_code] = 1
    expect(cmd[:exit_code]).to eq(1)

    # Input
    expect(cmd[:input]).to eq("ruby --version")
    cmd2 = Command.new('')
    expect(cmd2[:input]).to eq('')

    # Output
    expect(cmd[:output]).to eq('')
    cmd[:output]='test'
    expect(cmd[:output]).to eq('test')

    # Error
    expect(cmd[:error]).to eq('')
    cmd[:error]='error_test'
    expect(cmd[:error]).to eq('error_test')

    # Machine
    expect(cmd[:machine]).to eq('')
    cmd[:machine]='machine_test'
    expect(cmd[:machine]).to eq('machine_test')

    # User
    expect(cmd[:user]).to eq('')
    cmd[:user]='user_test'
    expect(cmd[:user]).to eq('user_test')

    # StartTime
    expect(cmd[:start_time]).to eq(nil)
    cmd[:start_time]=Time.now
    expect(cmd[:start_time]).not_to eq(nil)

    # EndTime
    expect(cmd[:end_time]).to eq(nil)
    cmd[:end_time]=Time.now
    expect(cmd[:end_time]).not_to eq(nil)

    # summay
    expect(cmd.summary.include?('ruby')).to eq(true)
  end

  it "should be able to write to/load from JSON" do
    cmd=Command.new({ :input => 'ruby --version', :quiet => true, :exit_code=>12})
    expect(cmd[:timeout]).to eq(0)
    expect(cmd[:input]).to eq("ruby --version")
    cmd2=Command.new(JSON.parse(cmd.to_json))
    expect(cmd2[:timeout]).to eq(0)
    expect(cmd2[:input]).to eq("ruby --version")
  end

  it "should be able to timeout" do
    cmd=Command.new({ :input => 'ftp', :timeout => 0.5, :ignore_failure => true, :quiet => true})
    cmd.execute
    expect(cmd[:exit_code]).not_to eq(0)
  end


  it "should be able to execute rake command in specific directory" do
    dir="#{File.dirname(__FILE__)}/command_spec"
    Dir.make dir
    File.open("#{dir}/rakefile.rb","w") { |f| 
        f.puts "task :default do"
        f.puts " puts 'rake_test'"
        f.puts "end" 
        f.close
    }
    expect(File.exists?("#{dir}/rakefile.rb")).to eq(true)
    #cmd=Command.new({ :input => 'rake default', :quiet => true})
    cmd=Command.new({ :input => 'rake default', :quiet => true})#, :timeout => 2 })
    cmd[:directory]=dir
    expect(File.exists?(cmd[:directory])).to eq(true)
    cmd.execute
    #puts Command.execute('rake default', dir).summary
    # one line execution
    #puts Command.execute('rake default',dir).summary
    Dir.remove dir
  end

  it "should fail when calling rake produces an error" do
    dir="#{File.dirname(__FILE__)}/command_spec"
    FileUtils.mkdir_p(dir) if(!File.exists?(dir))
    File.open("#{dir}/rakefile.rb","w") { |f| 
        f.puts "task :default do"
        f.puts " raise 'rake_test'"
        f.puts "end" 
    }
    cmd=Command.new({ :input => 'rake', :ignore_failure => true, :quiet => true})
    cmd[:directory]=dir
    expect(File.exists?(cmd[:directory])).to eq(true)
    cmd.execute({:quiet => true})
    
    expect(cmd[:exit_code]).not_to eq(0)

    cmd=Command.new({ :input => 'rake bogus', :ignore_failure => true, :quiet => true})
    cmd[:directory]=dir
    expect(File.exists?(cmd[:directory])).to eq(true)
    cmd.execute
    expect(cmd[:exit_code]).not_to eq(0)

    cmd=Command.new({ :input => 'rake bogus', :timeout => 5.0, :ignore_failure => true, :quiet => true})
    cmd[:directory]=dir
    cmd.execute
    expect(cmd[:exit_code]).not_to eq(0)

    FileUtils.rm("#{dir}/rakefile.rb")
    begin
       FileUtils.rm_r(dir)
    rescue
    end
  end

  it "should be able to execute an array of commands" do
    help=['git --help']
    help << 'rake --help'
    help.env=Environment.new({ 'SUPPRESS_CONSOLE_OUTPUT' => 'true' })
    help.execute({:quiet => true})
    File.open('help.html','w'){|f|f.write(help.to_html)}
  end

  it "should be able to execute a hash with arrays or commands" do
    commands=Hash.new
    commands[:help]=['git --help','rake --help']
    commands[:version]=['git --version']
    commands[:help].env=Environment.new({ 'SUPPRESS_CONSOLE_OUTPUT' => 'true' })
    commands[:version].env=Environment.new({ 'SUPPRESS_CONSOLE_OUTPUT' => 'true' })
    commands.execute({:quiet => true})
  end

  it "should be able to get the output" do
    expect(Command.output('git --version').include?('git version')).to eq(true)
    expect(Command.output('bogus --version').include?('bogus version')).to eq(false)
  end

  it "should be able to get the exit_code" do
    expect(Command.exit_code('rake --version')).to eq(0)
    expect(Command.exit_code('bogus --version')).not_to eq(0)
  end
end