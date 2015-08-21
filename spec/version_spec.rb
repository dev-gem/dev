require_relative '../lib/base/version.rb'
require 'fileutils'

describe Version do

	it "should be extract the version from AssemblyInfo.cs" do
		FileUtils.mkdir("#{File.dirname(__FILE__)}/version_spec") if(!File.exists?("#{File.dirname(__FILE__)}/version_spec"))
		Dir.chdir("#{File.dirname(__FILE__)}/version_spec") do
			File.open('AssemblyInfo.cs','w'){|f|f.write('[assembly: AssemblyVersion("1.2.3")]')}
			expect(Version.read('AssemblyInfo.cs')).to eq('1.2.3'), "version 1.2.3 was not extracted from AssemblyInfo.cs"
		end		
		FileUtils.rm_r "#{File.dirname(__FILE__)}/version_spec"
	end
end