# frozen_string_literal: true

require_relative "../lib/apps/svn"
require "rake"
describe Svn do
  it "should be able to detect changes" do
    FileUtils.mkdir("#{File.dirname(__FILE__)}/svn_spec") unless File.exist?("#{File.dirname(__FILE__)}/svn_spec")
    unless File.exist?("#{File.dirname(__FILE__)}/svn_spec/svn_changes_test")
      FileUtils.mkdir("#{File.dirname(__FILE__)}/svn_spec/svn_changes_test")
    end

    svn_repo = "file:///#{File.dirname(__FILE__)}/svn_spec/svn_changes_test/change_repo"

    unless svn_repo.include?(" ")
      Dir.chdir("#{File.dirname(__FILE__)}/svn_spec/svn_changes_test") do
        Dir.remove("change_repo") if File.exist?("change_repo")
        `svnadmin create change_repo 2>&1`
        `svn checkout #{svn_repo} ctrunk`
        File.open("ctrunk/file1.txt", "w") { |f| f.write("abc") }
        File.open("ctrunk/file2.txt", "w") { |f| f.write("abc") }
        Dir.chdir("ctrunk") do
          `svn add file1.txt`
          `svn add file2.txt`
          `svn commit -m'all'`
          expect(Svn.has_changes?).to eq(false)
          File.open("file1.txt", "w") { |f| f.write("def") }
          File.open("file2.txt", "w") { |f| f.write("def") }
          expect(Svn.has_changes?).to eq(true)
          `svn commit -m'all'`
          expect(Svn.has_changes?).to eq(false)
        end
        Dir.remove "ctrunk"
        Dir.remove "change_repo"
      end
    end
    Dir.remove "#{File.dirname(__FILE__)}/svn_spec"
  end

  it "should be able to publish files to a subversion repository" do
    dir = "#{File.dirname(__FILE__)}/svn_spec"
    Dir.remove dir
    Dir.make dir
    # FileUtils.mkdir(dir) if(!File.exists?(dir))
    svn_repo = "file:///#{File.dirname(__FILE__)}/svn_spec/svn_test_repo"
    # sleep(1)
    Dir.chdir(dir) do
      FileUtils.rm_r("svn_test_repo") if File.exist?("svn_test_repo")
      `svnadmin create svn_test_repo 2>&1`
      expect(File.exist?("svn_test_repo")).to eq(true)

      FileUtils.rm_r("to_publish") if File.exist?("to_publish")
      FileUtils.mkdir("to_publish") unless File.exist?("to_publish")
      File.open("to_publish/file1.txt", "w") { |f| f.write("abc") }
      File.open("to_publish/file2.txt", "w") { |f| f.write("def") }
      File.open("to_publish/file3.text", "w") { |f| f.write("ghi") }
      File.open("to_publish/file4.dat", "w") { |f| f.write("jkl") }

      svn_dest = "#{svn_repo}/to_publish"

      unless __FILE__.include?(" ")
        # Svn.publish svn_dest, "#{File.dirname(__FILE__)}/svn_spec/to_publish", FileList.new('*.txt','*.dat')#  ['*.txt','*.dat']
        # expect(`svn info #{svn_dest}`.include?('Revision:')).to eq(true)
        # expect(`svn info #{svn_dest}/file1.txt`.include?('Revision:')).to eq(true)
        # expect(`svn info #{svn_dest}/file2.txt`.include?('Revision:')).to eq(true)
        # expect(`svn info #{svn_dest}/file3.text 2>&1`.include?('Revision:')).to eq(false)
        # expect(`svn info #{svn_dest}/file4.dat 2>&1`.include?('Revision:')).to eq(true)

        # Dir.remove('to_publish')
        # expect(File.exists?('to_publish')).to eq(false)
        # Dir.remove('svn_test_repo')
        # expect(File.exists?('svn_test_repo')).to eq(false)
      end
    end
    Dir.remove dir
  end
end
