require_relative '../lib/base/environment.rb'

describe Environment do

  it "should have a valid home directory" do
    expect(File.exists?(Environment.home)).to eq(true)
  end

  it "should have a valid machine name" do
    expect(Environment.machine.length).to be > 0
  end

  it "should have a valid user name" do
    expect(Environment.user.length).to be > 0
  end

  it "should have a valid dev_root" do
  	expect(File.exists?(Environment.dev_root)).to eq(true)
  end

  it "should be able to get_latest_mtime" do
    expect(Environment.get_latest_mtime(File.dirname(__FILE__))).not_to eq(nil)
  end
end