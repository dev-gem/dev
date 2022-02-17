# frozen_string_literal: true

require_relative "../lib/base/version"
require "fileutils"

describe Version do
  it "should be able to extract the version from a string" do
    expect(Version.extract("")).to eq(nil)
    expect(Version.extract("version = '2.0.268'")).to eq("2.0.268")
    expect(Version.extract('version = "2.0.268"')).to eq("2.0.268")
    expect(Version.extract('[assembly: AssemblyVersion("3.0.15" )]')).to eq("3.0.15")
    expect(Version.extract('[assembly: AssemblyFileVersion("2.0.15" )]')).to eq("2.0.15")
    expect(Version.extract('Version = "2.1.0"')).to eq("2.1.0")
    expect(Version.extract('Version="1.2.0"')).to eq("1.2.0")
  end

  it "should be able to update text with a new version" do
    expect(Version.update_text("version = '2.0.269'", "1.2.3")).to eq("version='1.2.3'")
    expect(Version.update_text('version = "2.0.269"', "1.2.3")).to eq('version="1.2.3"')
    expect(Version.update_text("Version = '2.0.269'", "1.2.3")).to eq("Version='1.2.3'")
    expect(Version.update_text('Version = "2.0.269"', "1.2.3")).to eq('Version="1.2.3"')
    expect(Version.update_text('AssemblyVersion("1.0.2")', "1.2.3")).to eq('AssemblyVersion("1.2.3")')
    expect(Version.update_text('AssemblyFileVersion("1.0.2")', "1.2.3")).to eq('AssemblyFileVersion("1.2.3")')
    expect(Version.update_text('Name="Version" Value="0.0.1"', "1.2.3")).to eq('Name="Version" Value="1.2.3"')
  end

  it "should be extract the version from AssemblyInfo.cs" do
    unless File.exist?("#{File.dirname(__FILE__)}/version_spec")
      FileUtils.mkdir("#{File.dirname(__FILE__)}/version_spec")
    end
    Dir.chdir("#{File.dirname(__FILE__)}/version_spec") do
      File.open("AssemblyInfo.cs", "w") { |f| f.write('[assembly: AssemblyVersion("1.2.3")]') }
      expect(Version.read("AssemblyInfo.cs")).to eq("1.2.3"), "version 1.2.3 was not extracted from AssemblyInfo.cs"
      expect(Version.get_version).to eq("1.2.3")
    end
    FileUtils.rm_r "#{File.dirname(__FILE__)}/version_spec"
  end
end
