# frozen_string_literal: true

require_relative '../lib/base/file'
require_relative '../lib/base/environment'
require 'rake'

describe File do
  it 'should be able to publish a directory' do
    dir = "#{File.dirname(__FILE__)}/file_spec" unless File.exist?("#{File.dirname(__FILE__)}/file_spec")
    FileUtils.rm_rf("#{dir}/publish_test_dest") if File.exist? "#{dir}/publish_test_dest"

    FileUtils.mkdir_p dir unless File.exist? dir
    FileUtils.mkdir_p "#{dir}/publish_test" unless File.exist? "#{dir}/publish_test"
    FileUtils.mkdir_p "#{dir}/publish_test/a" unless File.exist? "#{dir}/publish_test/a"
    File.open("#{dir}/publish_test/a/b.txt", 'w') { |f| f.write('c') }

    File.publish "#{dir}/publish_test_dest", "#{dir}/publish_test", FileList.new('**/*.txt')
    expect(File.exist?("#{dir}/publish_test_dest/a/b.txt")).to eq(true)

    FileUtils.rm_rf(dir)
  end
end
