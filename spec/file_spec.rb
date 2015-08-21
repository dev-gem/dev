require_relative '../lib/base/file.rb'
require_relative '../lib/base/environment.rb'
require 'rake'

describe File do

  it "should be able to publish a directory" do
    dir="#{File.dirname(__FILE__)}/file_spec" if(!File.exists?("#{File.dirname(__FILE__)}/file_spec"))
    FileUtils.rm_rf("#{dir}/publish_test_dest") if File.exists? "#{dir}/publish_test_dest"
    
    FileUtils.mkdir_p dir if !File.exists? dir
    FileUtils.mkdir_p "#{dir}/publish_test" if !File.exists? "#{dir}/publish_test"
    FileUtils.mkdir_p "#{dir}/publish_test/a" if !File.exists? "#{dir}/publish_test/a"
    File.open("#{dir}/publish_test/a/b.txt",'w'){|f|f.write('c')}

    File.publish "#{dir}/publish_test_dest", "#{dir}/publish_test", FileList.new('**/*.txt')
    expect(File.exists?("#{dir}/publish_test_dest/a/b.txt")).to eq(true)
    
    FileUtils.rm_rf(dir)
  end

end