require_relative '../lib/base/project.rb'
require_relative '../lib/base/command.rb'
require_relative '../lib/base/environment.rb'
require 'rake'

describe Project do

	it "should be able to automatically initialize properties from url constructor" do
		hellogem=Project.new('http://github.com/dev-gem/HelloRubyGem.git')
		expect(hellogem.url).to eq('http://github.com/dev-gem/HelloRubyGem.git')
		expect(hellogem.fullname).to eq('github/dev-gem/HelloRubyGem')
		expect(hellogem.name).to eq('HelloRubyGem')
		expect(hellogem.make_dir('0.0.0')).to eq("#{Environment.dev_root}/make/github/dev-gem/HelloRubyGem-0.0.0")
	end

	it "should be able to make a specific tag" do
		hellogem=Project.new('http://github.com/lou-parslow/hello.gem.git')
		makedir="#{Environment.dev_root}/make/github/lou-parslow/hello.gem-0.0.0"
		FileUtils.rm_r(makedir) if File.exists? makedir

		logfile="#{Environment.dev_root}/log/#{hellogem.fullname}/0.0.0/#{Environment.user}@#{Environment.machine}.json"
		File.delete(logfile) if File.exists? logfile
		make=hellogem.make('0.0.0')
		expect(File.exists?(makedir)).to eq(false),"#{makedir} exists after hello.make('0.0.0')"
		if(make[:exit_code] != 0)
			expect(false).to eq(true),"hellogem.make('0.0.0') exit code=#{make[:exit_code]}\n#{make[:output]}\n#{make[:error]}"
		end
		expect(make[:exit_code]).to eq(0),"hellogem.make('0.0.0') failed."
		expect(File.exists?(logfile)).to eq(true), "#{logfile} does not exists after hellogem.make('0.0.0')"
		hellogem.clobber
		expect(File.exists?(makedir)).to eq(false)
	end

	it "should be able to list tags" do
		hellogem=Project.new('http://github.com/lou-parslow/hello.gem.git')
		#expect(hellogem.tags.include?('0.0.0')).to eq(true), 'hellogem.tags did not include '0.0.0'
	end
end