# frozen_string_literal: true

class GitUrl
  def self.pull(url)
    if url.is_a?(Array)
      url.each { |u| GitUrl.pull u }
    else
      puts " "
      work_dir = get_work_dir(url)
      unless Dir.exist?(work_dir)
        puts "git clone #{url} #{work_dir}"
        puts `git clone #{url} #{work_dir}`
      end

      Dir.chdir(work_dir) do
        puts "git pull (#{work_dir})"
        puts `git pull`
      end
    end
  end

  def self.build(url)
    if url.is_a?(Array)
      url.each { |u| GitUrl.build u }
    else
      GitUrl.pull url
      puts "build #{url}"
      work_dir = get_work_dir(url)
      puts "work_dir #{work_dir}"

      Dir.chdir(work_dir) do
        puts "rake #{work_dir}"
        puts `rake`
        puts "rake clobber"
        puts `rake clobber`
      end
    end
  end

  def self.update_build_repo(url)
    local_dir = "#{Environment.dev_root}/build/#{get_relative_dir(url)}"
    unless Dir.exist?(local_dir)
      puts "git clone #{url} #{local_dir}"
      puts `git clone #{url} #{local_dir}`
    end
    stags = ""
    Dir.chdir(local_dir) do
      puts `git pull`
    end
  end

  def self.build_tags(url)
    if url.is_a?(Array)
      url.each { |u| GitUrl.build_tags u }
    else
      puts "GitUrl.build_tags #{url}"
      local_dir = "#{Environment.dev_root}/build/#{get_relative_dir(url)}"
      unless Dir.exist?(local_dir)
        puts "git clone #{url} #{local_dir}"
        puts `git clone #{url} #{local_dir}`
      end
      stags = ""
      Dir.chdir(local_dir) do
        puts `git pull`
        stags = `git tag`.gsub('\r', "")
      end
      tags = stags.split("\n").reverse
      puts "tags: #{tags}"
      tags.each do |tag|
        build_tag url, tag.strip
      end
    end
  end

  def self.build_tag(url, tag)
    build_dir = get_build_dir_tag(url, tag)
    unless Dir.exist?(build_dir)
      puts "git clone -b #{tag} --single-branch --depth 1 #{url} #{build_dir}"
      puts `git clone -b #{tag} --single-branch --depth 1 #{url} #{build_dir}`

      if Dir.exist?(build_dir)
        Dir.chdir(build_dir) do
          puts "rake #{build_dir}"
          puts `rake`
        end
      end
    end
  end

  def self.get_work_dir(url)
    "#{Environment.dev_root}/work/#{get_relative_dir(url)}"
  end

  def self.get_build_dir(url)
    "#{Environment.dev_root}/build/#{get_relative_dir(url)}"
  end

  def self.get_build_dir_tag(url, tag)
    "#{Environment.dev_root}/build/#{get_relative_dir(url)}-#{tag}"
  end

  def self.get_relative_dir(url)
    url.gsub("http://", "").gsub("https://", "").gsub(".git", "")
  end
end
