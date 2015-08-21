require_relative('../lib/dev.rb')

describe Dev do

    it "should be able to make HelloRubyGem" do
        dir="#{File.dirname(__FILE__)}/dev_spec_HelloRubyGem"
        FileUtils.rm_r dir if File.exists? dir
        `git clone http://github.com/dev-gem/HelloRubyGem.git #{dir}`
        Dir.chdir(dir) do
            FileUtils.rm_r '.git'
            Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
            Command.execute('rake default')
            #rake_default=Command.new({:input=>'rake default',:ignore_failure=> true, :quiet => true})
            #rake_default.execute
            #if(rake_default[:exit_code] != 0)
            #    puts rake_default[:output]
            #    puts rake_default[:error]
            #end
            #expect(Command.exit_code('rake default')).to eq(0)
        end
        FileUtils.rm_r dir
    end

    it "should be able to define rake tasks for the gem-example" do
        dir="#{File.dirname(__FILE__)}/dev_spec/hello.gem"
        FileUtils.rm_r dir if File.exists? dir
        FileUtils.mkdir_p dir if !File.exists?(dir)
        `git clone https://github.com/lou-parslow/hello.gem.git #{dir}`
        Dir.chdir(dir) do
           FileUtils.rm_r '.git'
           Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../../lib/dev.rb')")
           rake_default=Command.new({:input=>'rake default',:ignore_failure=> true, :quiet => true})
           rake_default.execute
           if(rake_default[:exit_code] != 0)
             puts rake_default[:output]
             puts rake_default[:error]
           end
           expect(Command.exit_code('rake default')).to eq(0)
           expect(Command.output('rake info').include?('Project hello.gem'))
           expect(Command.exit_code('rake clobber')).to eq(0)
        end
        FileUtils.rm_r "#{File.dirname(__FILE__)}/dev_spec"
    end

	it "should be able to make HelloCSharpLibrary" do
    	#dir="#{File.dirname(__FILE__)}/dev_spec/HelloLibrary"
    	#FileUtils.mkdir_p dir if !File.exists?(dir)
    	#{}`git clone https://gitlab.com/lou-parslow/HelloLibrary.git #{dir}`
    	#Dir.chdir(dir) do
        #    FileUtils.rm_r '.git'
    	#	Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../../lib/dev.rb')")
    	#	expect(Command.exit_code('rake build')).to eq(0)
    	#	expect(Command.output('rake info').include?('Project HelloLibrary'))
    	#	expect(Command.exit_code('rake clobber')).to eq(0)
    	#end
    	#FileUtils.rm_r "#{File.dirname(__FILE__)}/dev_spec"
	end

	it "should be able to define rake tasks for HelloConsole" do
		#FileUtils.mkdir_p "#{File.dirname(__FILE__)}/dev_spec" if !File.exists?("#{File.dirname(__FILE__)}/dev_spec")
    	#dir="#{File.dirname(__FILE__)}/dev_spec/HelloConsole"
    	
    	#{}`git clone https://gitlab.com/lou-parslow/HelloConsole.git #{dir}`
    	#Dir.chdir(dir) do
        #    FileUtils.rm_r '.git'
        #    Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../../lib/dev.rb')")
    	#	rake=Command.new('rake build')
    	#	rake.execute
    	#	if(rake[:exit_code] != 0)
    	#		puts rake[:output]
    	#		puts rake[:error]
    	#	end
    	#	expect(Command.exit_code('rake default')).to eq(0)
    	#end
    	#FileUtils.rm_r dir
    	#FileUtils.rm_r "#{File.dirname(__FILE__)}/dev_spec"
	end
end