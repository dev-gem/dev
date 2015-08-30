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
        dev.execute('work')
        dev.execute('make')
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
        if(!dev.env.output.include?('ok'))
            puts 'info output:'
            puts dev.env.output
        end
        expect(dev.env.output.include?('ok')).to eq true 
        Dir.remove dir
    end

    it "should be able to perform make for a specific project" do
        dir="#{File.dirname(__FILE__)}/dev_spec"
        Dir.remove dir
        Dir.make dir
        dev=Dev.new( { 'DEV_ROOT' => dir, 'SUPPRESS_CONSOLE_OUTPUT' => 'true' } )
        dev.execute('add http://github.com/dev-gem/HelloRake.git')
        expect(dev.execute('make HelloRake')).to eq 0 
        dev.env.output=''
        expect(dev.execute('info')).to eq 0
        expect(dev.env.output.include?('ok')).to eq true 
        Dir.remove dir
    end
end