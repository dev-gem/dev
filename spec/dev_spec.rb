require_relative('../lib/dev.rb')

describe Dev do

    it "should be able to make HelloRubyGem" do
        dir="#{File.dirname(__FILE__)}/dev_spec_HelloRubyGem"
        FileUtils.rm_r dir if File.exists? dir
        Command.exit_code("git clone http://github.com/dev-gem/HelloRubyGem.git #{dir}")
        Dir.chdir(dir) do
            FileUtils.rm_r '.git'
            Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
            publish_file="#{Environment.dev_root}/publish/HelloRubyGem-#{Version.get_version}.gem"
            File.delete publish_file if File.exists? publish_file
            expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
            Command.exit_code('rake default')
            expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
        end
        FileUtils.rm_r dir
    end

	it "should be able to make HelloCSharpLibrary" do
    	dir="#{File.dirname(__FILE__)}/dev_spec_HelloCSharpLibrary"
        FileUtils.rm_r dir if File.exists? dir
        Command.exit_code("git clone http://github.com/dev-gem/HelloCSharpLibrary.git #{dir}")
        Dir.chdir(dir) do
            FileUtils.rm_r '.git'
            Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
            publish_file="#{Environment.dev_root}/publish/HelloCSharpLibrary.#{Version.get_version}.nupkg"
            File.delete publish_file if File.exists? publish_file
            expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
            Command.exit_code('rake default')
            expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
            #Dev.execute(['make',' github/dev-gem/HelloCSharpLibrary'])
        end
        FileUtils.rm_r dir
	end

	it "should be able to make HelloCSharpConsole" do
        dir="#{File.dirname(__FILE__)}/dev_spec_HelloCSharpConsole"
        FileUtils.rm_r dir if File.exists? dir
        Command.exit_code("git clone http://github.com/dev-gem/HelloCSharpConsole.git #{dir}")
        Dir.chdir(dir) do
            FileUtils.rm_r '.git'
            Text.replace_in_file('rakefile.rb',"require 'dev'","require_relative('../../lib/dev.rb')")
            publish_file="#{Environment.dev_root}/publish/HelloCSharpConsole-#{Version.get_version}.msi"
            File.delete publish_file if File.exists? publish_file
            expect(File.exists?(publish_file)).to eq(false), "#{publish_file} was not cleaned up"
            Command.exit_code('rake default')
            expect(File.exists?(publish_file)).to eq(true), "#{publish_file} does not exist after rake default"
        end
        FileUtils.rm_r dir
    end
end