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

    it "should be able to perform add, work and make for a specific project" do
        dir="#{File.dirname(__FILE__)}/dev_spec"
        Dir.remove dir
        Dir.make dir
        dev=Dev.new( { 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true' } )

        # INIT REPO HelloRake.git
        Dir.chdir(dir) do
            cmd=Command.execute('git init --bare HelloRake.git')
            cmd=Command.execute("git clone #{dir}/HelloRake.git")
            Dir.chdir("#{dir}/HelloRake") do
                File.open('rakefile.rb','w'){|f|f.puts 'task :default do; puts "ok"; end'}
                cmd=Command.execute('git add rakefile.rb')
                cmd=Command.execute('git commit -m"added rakefile.rb"')
                cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
                cmd=Command.execute('git push')
                cmd=Command.execute('git push --tags')
            end
        end

        # ADD
        dev.execute("add #{dir}/HelloRake.git local/HelloRake")

        # WORK
        expect(dev.execute('work HelloRake')).to eq 0 
        dev.env.output=''

        # MAKE
        expect(dev.execute('make HelloRake')).to eq 0 
        Dir.remove dir
    end

    it "should be able to perform work and make timeouts for infinite loop project" do
        dir="#{File.dirname(__FILE__)}/dev_spec"
        Dir.remove dir
        Dir.make dir
        dev=Dev.new( { 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true' } )

        # INIT REPO HelloRake.git
        Dir.chdir(dir) do
            cmd=Command.execute('git init --bare HelloRake.git')
            cmd=Command.execute("git clone #{dir}/HelloRake.git")
            Dir.chdir("#{dir}/HelloRake") do
                File.open('rakefile.rb','w'){|f|f.puts "task :default do; while(true do; sleep(60);puts 'x';end; end"}
                cmd=Command.execute('git add rakefile.rb')
                cmd=Command.execute('git commit -m"added rakefile.rb"')
                cmd=Command.execute('git tag 0.0.0 -m"0.0.0"')
                cmd=Command.execute('git push')
                cmd=Command.execute('git push --tags')
            end
        end

        # ADD
        dev.execute("add #{dir}/HelloRake.git local/HelloRake 1s")

        # WORK
        expect(dev.execute('work HelloRake')).not_to eq 0 
        dev.env.output=''

        # MAKE
        expect(dev.execute('make HelloRake')).not_to eq 0 
        Dir.remove dir
    end
end