require_relative '../lib/apps/msbuild.rb'

describe MSBuild do
	it "should be able to automatically generate commands for the sln-vs12-example directory" do
    #dir='spec/sln-vs12-example'
    #expect(File.exists?("#{dir}/rakefile.rb")).to eq(true)

    #Dir.chdir(dir) do

    #  sln_file='example.sln'
    #  expect(File.exists?(sln_file)).to eq(true)
    #  build_commands=MSBuild.get_build_commands sln_file
    #  if(RUBY_PLATFORM.include?("mingw"))
    #  	expect(build_commands.length).to eq(6)
    #  end
    #end
  end

  it "should be able to automatically generate commands for the sln-vs9-example directory" do
      #dir='spec/sln-vs9-example'
      #expect(File.exists?("#{dir}/rakefile.rb")).to eq(true)

      #Dir.chdir(dir) do

      #  sln_file='example.sln'
      #  expect(File.exists?(sln_file)).to eq(true)
      #  build_commands=MSBuild.get_build_commands sln_file
      #  if(RUBY_PLATFORM.include?("mingw"))
      #    expect(build_commands.length).to eq(6)
      #  end
      #end
  end

end