require_relative '../lib/base/environment.rb'

describe Environment do

  it "should support some basic environment variables" do
    env=Environment.new
    expect(File.exists?(env.get_env('HOME'))).to eq(true)
    expect(File.exists?(env.get_env('DEV_ROOT'))).to eq(true)
    expect(env.debug?).to eq(false)
    expect(File.exist?(env.home_dir)).to eq(true)
    expect(File.exist?(env.log_dir)).to eq(true)
    expect(File.exist?(env.make_dir)).to eq(true)
    expect(File.exist?(env.wrk_dir)).to eq(true)
    expect(env.machine.length).to be > 0
    expect(env.user.length).to be > 0
  end

  it "should be able to modify it environment variables independently" do
    env1=Environment.new
    #FileUtils.mkdir('dev_spec') if !File.exists?('dev_spec')
    env2=Environment.new( { 'DEV_ROOT' => "#{File.dirname(__FILE__)}/dev_spec", 'DEBUG'=>'true' } )
    expect(env2.debug?).to eq(true)
    #dev2.set_env 'DEV_ROOT', "#{File.dirname(__FILE__)}/dev_spec"
    expect(env1.get_env('DEV_ROOT')).not_to eq(env2.get_env('DEV_ROOT'))
    #Environment.remove('dev_spec')
  end

  #it "should have a valid home directory" do
  #  expect(File.exists?(Environment.home)).to eq(true)
  #end

  #it "should have a valid machine name" do
  #  expect(Environment.machine.length).to be > 0
  #end

  #it "should have a valid user name" do
  #  expect(Environment.user.length).to be > 0
  #end

  #it "should have a valid dev_root" do
  #	expect(File.exists?(Environment.dev_root)).to eq(true)
  #end

  it "should be able to get_latest_mtime" do
    expect(Environment.get_latest_mtime(File.dirname(__FILE__))).not_to eq(nil)
  end


end