require_relative '../lib/base/project.rb'
require_relative '../lib/base/command.rb'
require_relative '../lib/base/dir.rb'
require_relative '../lib/base/environment.rb'
require 'rake'

describe Project do

	it "should be able to automatically initialize properties from url constructor" do
		hellogem=Project.new('http://github.com/dev-gem/HelloRubyGem.git')
		hellogem.env.set_env('SUPPRESS_CONSOLE_OUTPUT','true')

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
        helloRake.env=Environment.new({ 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true'})

        # MAKE
        expect(helloRake.command_history.length).to eq(0)
        expect(helloRake.make('0.0.0').exit_code).to eq(0)
        expect(File.exists?(helloRake.get_logfile(['make','0.0.0']))).to eq(true)
        expect(helloRake.command_history.length).to eq(1)

        # WORK
        expect(helloRake.work.exit_code).to eq(0)
        expect(helloRake.command_history.length).to eq(2)

        # CLOBBER
        expect(helloRake.clobber.exit_code).to eq(0)
        expect(File.exists?(helloRake.wrk_dir)).to eq(false)
        expect(File.exists?(File.dirname(helloRake.wrk_dir))).to eq(false)

        Dir.remove dir
    end
end