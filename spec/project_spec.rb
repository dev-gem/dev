require_relative '../lib/base/project.rb'
require_relative '../lib/base/command.rb'
require_relative '../lib/base/dir.rb'
require_relative '../lib/base/environment.rb'
require 'rake'

describe Project do

	it "should be able to automatically initialize properties from url constructor" do
		hellogem=Project.new('http://github.com/dev-gem/HelloRubyGem.git')
		expect(hellogem.url).to eq('http://github.com/dev-gem/HelloRubyGem.git')
		expect(hellogem.fullname).to eq('github/dev-gem/HelloRubyGem')
		expect(hellogem.name).to eq('HelloRubyGem')
		expect(hellogem.make_dir('0.0.0')).to eq("#{hellogem.env.root_dir}/make/github/dev-gem/HelloRubyGem-0.0.0")
	end

	it "should be able to perform basic tasks for HelloRake project" do
        dir="#{File.dirname(__FILE__)}/project_spec"
        Dir.remove dir
        Dir.make dir
        helloRake=Project.new('https://github.com/dev-gem/HelloRake.git')
        helloRake.env=Environment.new({ 'DEV_ROOT' => dir, 'DEBUG' => 'true'})
        expect(helloRake.env.debug?).to eq(true)
        #expect(helloRake.log_filenames.length).to eq(0)
        expect(helloRake.command_history.length).to eq(0)
        expect(helloRake.make('0.0.0').exit_code).to eq(0)
        expect(File.exists?(helloRake.get_logfile(['make','0.0.0']))).to eq(true)
        expect(helloRake.command_history.length).to eq(1)
       # logfile=get_logfile ['make',tag]
        #dev=Dev.new( { 'DEV_ROOT' => dir, 'DEBUG' => 'true'} )
        #dev.execute('add http://github.com/dev-gem/HelloRake.git')
        #helloRake=dev.projects['github.com/dev-gem/HelloRake']
        expect(helloRake).not_to eq(nil)


        #expect(File.exists?("#{dir}/data/Projects.json")).to eq(true)
        #expect(dev.projects.has_key?('github/dev-gem/HelloRake')).to eq(true)
        #expect(dev.projects.length).to eq(1)
        #expect(dev.projects.get_projects.length).to eq(1)
        #expect(dev.history.get_wrk_command('github/dev-gem/HelloRake')).to eq (nil)
        #dev.execute('work')
        #expect(dev.history.get_wrk_command('github/dev-gem/HelloRake')).not_to eq (nil)
        #expect(dev.history.get_commands('github/dev-gem/HelloRake').length).to eq(1)
        #dev.execute('make')
        #expect(dev.history.get_commands('github/dev-gem/HelloRake').length).to eq(2)
        #expect(File.exists?()).to eq(true)
        Dir.remove dir
    end

	#it "should be able to make a specific tag" do
	#	hellogem=Project.new('http://github.com/dev-gem/HelloRubyGem.git')
	#	makedir="#{Environment.dev_root}/make/github/dev-gem/HelloRubyGem-0.0.0"
	#	FileUtils.rm_r(makedir) if File.exists? makedir

	#	logfile="#{Environment.dev_root}/log/#{hellogem.fullname}/0.0.0/#{Environment.user}@#{Environment.machine}.json"
	#	File.delete(logfile) if File.exists? logfile

	#	publish_file="#{Environment.dev_root}/publish/HelloRubyGem-0.0.0.gem"
    #    File.delete publish_file if File.exists? publish_file

	#	make=hellogem.make('0.0.0')
	#	expect(File.exists?(makedir)).to eq(false),"#{makedir} exists after hello.make('0.0.0')"
	#	expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
	#	if(make[:exit_code] != 0)
	#		expect(false).to eq(true),"hellogem.make('0.0.0') exit code=#{make[:exit_code]}\n#{make[:output]}\n#{make[:error]}"
	#	end
	#	expect(make[:exit_code]).to eq(0),"hellogem.make('0.0.0') failed."
	#	expect(File.exists?(logfile)).to eq(true), "#{logfile} does not exists after hellogem.make('0.0.0')"
	#	hellogem.clobber
	#	expect(File.exists?(makedir)).to eq(false)
	#end

	it "should be able to list tags" do
		hellogem=Project.new('http://github.com/dev-gem/HelloRubyGem.git')
		#expect(hellogem.tags.include?('0.0.0')).to eq(true), 'hellogem.tags did not include '0.0.0'
	end
end