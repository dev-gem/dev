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

         # INIT REPO HelloRake.git
        Dir.chdir(dir) do
            cmd=Command.execute('git init --bare HelloRake.git')
            cmd=Command.execute("git clone \"#{dir}/HelloRake.git\"")
            Dir.chdir("#{dir}/HelloRake") do
                File.open('rakefile.rb','w'){|f|f.puts 'task :default do; puts "ok"; end'}
                cmd=Command.execute('git config user.email "lou-parslow+dev.gem@gamail.com"') if Git.user_email.length < 1
                cmd=Command.execute('git config user.name "lou-parslow"') if Git.user_name.length < 1
                cmd=Command.execute('git config --global push.default simple') 
                cmd=Command.execute('git add rakefile.rb')
                cmd=Command.execute('git commit -m"added rakefile.rb"')
                cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
                cmd=Command.execute('git push')
                cmd=Command.execute('git push --tags')
            end
        end

        # ADD
        helloRake=Project.new("#{dir}/HelloRake.git", 'local/HelloRake')
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

    it "should fail work and make if there is not rakefile" do
        dir="#{File.dirname(__FILE__)}/project_spec"
        Dir.remove dir
        Dir.make dir
        sleep(0.5)

         # INIT REPO HelloRake.git
        Dir.chdir(dir) do
            cmd=Command.execute('git init --bare HelloRake.git')
            cmd=Command.execute("git clone \"#{dir}/HelloRake.git\"")
            Dir.chdir("#{dir}/HelloRake") do
                File.open('README.md','w'){|f|f.puts 'test'}
                cmd=Command.execute('git config user.email "lou-parslow+dev.gem@gamail.com"') if Git.user_email.length < 1
                cmd=Command.execute('git config user.name "lou-parslow"') if Git.user_name.length < 1
                cmd=Command.execute('git config --global push.default simple') 
                cmd=Command.execute('git add README.md')
                cmd=Command.execute('git commit -m"added README.md"')
                cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
                cmd=Command.execute('git push')
                cmd=Command.execute('git push --tags')
            end
        end

        # ADD
        helloRake=Project.new("#{dir}/HelloRake.git", 'local/HelloRake')
        helloRake.env=Environment.new({ 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true'})

        # WORK
        expect(helloRake.work.exit_code).to eq(1)

        # MAKE
        expect(helloRake.make('0.0.0').exit_code).to eq(1)

        Dir.remove dir
    end
end