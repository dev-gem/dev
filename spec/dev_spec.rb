require_relative('../lib/dev.rb')

describe Dev do

    it "should fail when passed an unrecognized argument" do
        dev=Dev.new({ 'SUPPRESS_CONSOLE_OUTPUT' => 'true'})
        expect(dev.execute('unknown')).to eq(1)
        expect(dev.env.output.include?('unknown command')).to eq true
    end

    it "should display usage when no args are passed to execute" do
        dev=Dev.new({ 'SUPPRESS_CONSOLE_OUTPUT' => 'true'})
        expect(dev.execute('')).to eq(0)
        expect(dev.env.output.include?('usage:')).to eq(true)
    end

    it "should be able to perform add of project" do
        dir="#{File.dirname(__FILE__)}/dev_root"
        Dir.remove dir
        Dir.make dir
        dev=Dev.new( { 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true'} )
        #expect(dev.env.debug?).to eq(true)
        expect(dev.projects.filename).to eq("#{dir}/data/Projects.json")
        expect(dev.projects.length).to eq(0)
        dev.execute('add http://github.com/dev-gem/HelloRake.git')
        expect(File.exists?("#{dir}/data/Projects.json")).to eq(true)
        expect(dev.projects.has_key?('github/dev-gem/HelloRake')).to eq(true)
        expect(dev.projects.length).to eq(1)
        expect(dev.projects.get_projects.length).to eq(1)
        #expect(dev.history.get_wrk_command('github/dev-gem/HelloRake')).to eq (nil)
        dev.execute('work')
        #expect(dev.history.get_wrk_command('github/dev-gem/HelloRake')).not_to eq (nil)
        #expect(dev.history.get_commands('github/dev-gem/HelloRake').length).to eq(1)
        dev.execute('make')
        #expect(dev.history.get_commands('github/dev-gem/HelloRake').length).to eq(2)
        #expect(File.exists?()).to eq(true)
        Dir.remove dir
    end

    it "should be able to perform work for a specific project" do
        dir="#{File.dirname(__FILE__)}/dev_spec"
        Dir.remove dir
        Dir.make dir
        dev=Dev.new( { 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true' } )
        dev.execute('add http://github.com/dev-gem/HelloRake.git')
        expect(dev.execute('work HelloRake')).to eq 0 
        dev.env.output=''
        expect(dev.execute('info')).to eq 0
        expect(dev.env.output.include?('ok')).to eq true 
        Dir.remove dir
    end

    #it "should be able to rake HelloRubyGem" do
    #    dir="#{File.dirname(__FILE__)}/dev_spec_HelloRubyGem"
    #    Environment.remove dir if File.exists? dir
    #    Command.exit_code("git clone http://github.com/dev-gem/HelloRubyGem.git #{dir}")
    #    Dir.chdir(dir) do
    #        Environment.remove '.git'
    #        Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
    #        publish_file="#{Environment.dev_root}/publish/HelloRubyGem-#{Version.get_version}.gem"
    #        File.delete publish_file if File.exists? publish_file
    #        expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
    #        Command.exit_code('rake default')
    #        expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
    #    end
    #    Environment.remove dir
    #end

	#it "should be able to rake HelloCSharpLibrary" do
    #	dir="#{File.dirname(__FILE__)}/dev_spec_HelloCSharpLibrary"
    #    FileUtils.rm_r dir if File.exists? dir
    #    Command.exit_code("git clone http://github.com/dev-gem/HelloCSharpLibrary.git #{dir}")
    #    Dir.chdir(dir) do
    #        FileUtils.rm_r '.git'
    #        Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
    #        publish_file="#{Environment.dev_root}/publish/HelloCSharpLibrary.#{Version.get_version}.nupkg"
    #        File.delete publish_file if File.exists? publish_file
    #        expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
    #        Command.exit_code('rake default')
    #        expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
    #    end
    #    FileUtils.rm_r dir
	#end

	#it "should be able to rake HelloCSharpConsole" do
    #    dir="#{File.dirname(__FILE__)}/dev_spec_HelloCSharpConsole"
    #    Environment.remove dir if File.exists? dir
    #    Command.exit_code("git clone http://github.com/dev-gem/HelloCSharpConsole.git #{dir}")
    #    Dir.chdir(dir) do
    #        Environment.remove '.git'
    #        Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
    #        publish_file="#{Environment.dev_root}/publish/HelloCSharpConsole-#{Version.get_version}.msi"
    #        File.delete publish_file if File.exists? publish_file
    #        expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
    #        Command.exit_code('rake default')
    #        expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
    #    end
    #    Environment.remove dir
    #end

    it "should be able to add and make projects" do
        #dir="#{File.dirname(__FILE__)}/dev_root"
        #Environment.remove dir
        #Environment.set_development_root dir
        #DEV.execute('add https://github.com/dev-gem/HelloRubyGem.git')
        #expect(File.exists?("#{dir}/data/Projects.json")).to equal(true)
        #DEV.execute('list')
        #DEV.execute('make')
        #DEV.execute('work')
        #DEV.execute('make HelloRubyGem')
        #expect(File.exists?("#{dir}/log/"))
        #Environment.set_development_root nil
        #FileUtils.rm_r dir
        #Environment.remove dir
    end
end