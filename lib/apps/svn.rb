# frozen_string_literal: true

require "fileutils"
require "tmpdir"
require_relative("../base/dir")

class Svn
  def self.latest_revision
    if Dir.exist?(".svn")
      `svn update`
      `svn info`.scan(/Last Changed Rev: (\d+)/).each do |m|
        return m.first.to_s
      end
    end
    "0"
  end

  def self.url
    if Dir.exist?(".svn")
      `svn info`.scan(%r{URL: ([:/.\-\d\w]+)}).each do |m|
        return m.first.to_s
      end
    end
    ""
  end

  def self.export(url, destination)
    `svn export #{url} #{destination}` unless File.exist?(destination.chomp("@"))
  end

  def self.has_changes?(directory = "")
    directory = Dir.pwd if directory.length.zero?
    Dir.chdir(directory) do
      return true if File.exist?(".svn") && `svn status`.scan(/^[MA]/).length.positive?
    end
    false
  end

  def self.add(source, directory = "")
    directory = Dir.pwd if directory.empty?
    Dir.chdir(directory) do
      source.each do |f|
        puts `svn add #{f} --parents` if `svn status #{f}`.include?("?")
        puts `svn add #{f} --parents` unless system("svn status #{f}")
      end
    end
  end

  def self.append_commit_message(_message, directory = "")
    directory = Dir.pwd if directory.empty?
    Dir.chdir(directory) do
    end
  end

  def self.commit(_message, directory = "")
    directory = Dir.pwd if directory.empty?
    Dir.chdir(directory) do
      # svn commit -F commit_message_filename
      puts `svn commit -m"commit all"`
      `svn update`
    end
  end

  # publish a directory to a new subversion path
  # source_dir is the directory with the files to be published
  # destination is the new subversion path URL
  # source_glob is a string or array of glob directives to specify files in source_dir to be publish
  # source_glob defaults to '**/*' to publish all files in the source_dir
  def self.publish(destination, source_dir, source_filelist = FileList.new("**/*"))
    # Support for legacy argument order
    if source_dir.include?("svn:") || source_dir.include?("http:") || source_dir.include?("https:")
      puts "warning arguments are in legacy order" if Environment.default.debug?
      # swap arguments
      tmp = source_dir
      source_dir = destination
      destination = tmp
    end

    unless source_filelist.is_a?(FileList)
      puts "converting files array into FileList" if Environment.default.debug?
      list = FileList.new
      source_filelist.each { |item| list.include(item) }
      source_fileList = list
    end

    output = "\n"
    if `svn info #{destination} 2>&1`.include?("Revision:")
      puts "Svn.publish: destination #{destination} already exists"
    else
      # create subversion directory
      output += "svn mkdir #{destination} --parents --message mkdir_for_publishing"
      unless `svn mkdir #{destination} --parents --message mkdir_for_publishing`.include?("Committed")
        raise "failure 'svn mkdir #{destination} --parents --message mkdir_for_publishing'"
      end

      Dir.chdir(source_dir) do
        files = source_filelist.to_a
      end
      files = source_filelist
      output = "#{output}\nfiles: "
      files.each do |f|
        output = "#{output}#{f} "
      end
      pwd = Dir.pwd

      dir = "#{Environment.default.tmp_dir}/svn_publish"
      Dir.remove dir if File.exist? dir
      FileUtils.mkdir dir
      Dir.chdir(dir) do
        # Dir.mktmpdir{|dir|

        # checkout new subversion directory
        output += "\nsvn checkout #{destination} #{dir}/to_publish_checkout"
        unless `svn checkout #{destination} #{dir}/to_publish_checkout`.include?("Checked out")
          raise "failure 'svn checkout #{destination} #{dir}/to_publish_checkout'"
        end

        # copy files into the checkout out subversion directory to_publish
        raise "#{dir}/to_publish_checkout does not exist" unless File.exist?("#{dir}/to_publish_checkout")

        Dir.chdir("#{dir}/to_publish_checkout") do
          File.open("add.txt", "w") do |add_file|
            files.each do |f|
              fdir = File.dirname(f)
              FileUtils.mkdir_p(fdir) if fdir.length.positive? && !File.exist?(fdir)
              FileUtils.cp("#{source_dir}/#{f}", f.to_s)
              add_file.puts f
            end
            add_file.close
          end

          output = "#{output}\nsvn add --parents --targets add.txt 2>&1"
          `svn add --parents --targets add.txt 2>&1`
          commit_output = `svn commit -m"add" 2>&1`
          output += "\n#{commit_output}"
          raise "failure 'svn commit -m'added files''#{output}" unless commit_output.include?("Committed")
        end

        # begin
        # Dir.remove "#{dir}/to_publish_checkout"
        output
      end
      Dir.remove(dir)
    end
  end
end
