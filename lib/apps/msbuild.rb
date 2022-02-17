# frozen_string_literal: true

puts DELIMITER if defined?(DEBUG)
puts __FILE__ if defined?(DEBUG)
# Visual Studio 2008 version 9.0,  solution format version 10.00
# Visual Studio 2010 version 10.0, solution format version 11.00
# Visual Studio 2012 version 11.0, solution format version 12.00
# Visual Studio 2013 version 12.0, solution format version 12.00
# Visual Studio 2015 version 14.0, solution format version 12.00
# Visual Studio 2017 version 15.0
# Visual Studio 2019 version 16.0
require "pp"

class MSBuild < Hash
  # @@ignore_configurations=Array.new
  def initialize
    add(:vs9, "C:/Windows/Microsoft.NET/Framework/v3.5/msbuild.exe")
    add(:vs10, "C:/Windows/Microsoft.NET/Framework/v4.0.30319/msbuild.exe")
    add(:vs12, "C:/Program Files (x86)/MSBuild/12.0/bin/msbuild.exe")
    add(:vs14, "C:/Program Files (x86)/MSBuild/14.0/bin/msbuild.exe")
    add(:vs15, "C:/Program Files (x86)/MSBuild/15.0/bin/msbuild.exe")
    add(:vs15, "C:/Program Files (x86)/Microsoft Visual Studio/2017/Enterprise/MSBuild/15.0/Bin/MSBuild.exe")
    if File.exist?("C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/MSBuild/15.0/Bin/MSBuild.exe")
      add(:vs15, "C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/MSBuild/15.0/Bin/MSBuild.exe")
    end
    if File.exist?("C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/MSBuild/Current/Bin/MSBuild.exe")
      add(:vs16, "C:/Program Files (x86)/Microsoft Visual Studio/2019/Enterprise/MSBuild/Current/Bin/MSBuild.exe")
    end
    if File.exist?("C:/Program Files (x86)/Microsoft Visual Studio/2019/Preview/MSBuild/Current/Bin/MSBuild.exe")
      add(:vs16, "C:/Program Files (x86)/Microsoft Visual Studio/2019/Preview/MSBuild/Current/Bin/MSBuild.exe")
    end
    if File.exist?("C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe")
      add(:vs16, "C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe")
    end
    if File.exist?("C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/MSBuild/Current/Bin/MSBuild.exe")
      add(:vs16, "C:/Program Files (x86)/Microsoft Visual Studio/2019/Professional/MSBuild/Current/Bin/MSBuild.exe")
    end
  end

  def add(key, name)
    self[key] = name if File.exist?(name)
  end

  def self.has_version?(version)
    if defined?(MSBUILD)
      MSBUILD.key?(version)
    else
      msb = MSBuild.new
      msb.key? version
    end
  end

  def self.in_path?
    command = Command.new("msbuild /version")
    command[:quiet] = true
    command[:ignore_failure] = true
    command.execute
    return true if (command[:exit_code]).zero?

    false
  end

  def self.get_version(version)
    return "msbuild" if MSBuild.in_path?

    if defined?(MSBUILD)
      MSBUILD[version]
    else
      msb = MSBuild.new
      msb[version]
    end
  end

  def self.get_vs_version(sln_filename)
    if sln_filename.nil?
      return :vs16 if has_version? :vs16
      return :vs15 if has_version? :vs15

      return :vs14
    end
    sln_text = File.read(sln_filename, encoding: "UTF-8")
    return :vs16 if sln_text.include?("Visual Studio Version 16")
    return :vs15 if sln_text.include?("VisualStudioVersion = 15.")
    return :vs9 if sln_text.include?("Format Version 10.00")
    return :vs12 if sln_text.include?("12.0.30723.0")
    return :vs12 if sln_text.include?("Visual Studio 2013")
    return :vs12 if sln_text.include?("12.0.31101.0")
    return :vs14 if sln_text.include?("VisualStudioVersion = 14.0.")
    return :vs16 if has_version? :vs16
    return :vs15 if has_version? :vs15

    :vs14
  end

  def self.get_configurations(sln_filename)
    configs = []
    sln_text = File.read(sln_filename, encoding: "UTF-8")
    sln_text.scan(/= (\w+)\|/).each do |m|
      c = m.first.to_s
      ignore = false
      ignore = true if defined?(IGNORE_CONFIGURATIONS) && IGNORE_CONFIGURATIONS.include?(c)
      configs << c if !ignore && !configs.include?(c)
    end
    configs
  end

  def self.get_platforms(sln_filename)
    platforms = []
    sln_text = File.read(sln_filename, encoding: "UTF-8")
    # sln_text.scan( /= [\w]+\|([\w ]+)/ ).each{|m|
    sln_text.scan(/\|([\w\d\s]+)\s*=/).each do |m|
      p = m.first.to_s.strip
      platforms << p unless platforms.include?(p)
    end
    platforms
  end

  def self.get_build_commands(sln_filename)
    build_commands = nil
    vs_version = MSBuild.get_vs_version(sln_filename)
    puts "vs version for '#{sln_filename}' : #{vs_version}"
    if MSBuild.has_version?(vs_version)
      MSBuild.get_configurations(sln_filename).each do |configuration|
        MSBuild.get_platforms(sln_filename).each do |platform|
          build_commands = [] if build_commands.nil?
          msbuild_arg = MSBuild.get_version(vs_version)
          msbuild_arg = "\"#{MSBuild.get_version(vs_version)}\"" if msbuild_arg.include?(" ")
          sln_arg = sln_filename
          sln_arg = "\"#{sln_filename}\"" if sln_filename.include?(" ")
          platform_arg = "/p:Platform=#{platform}"
          platform_arg = "/p:Platform=\"#{platform}\"" if platform.include?(" ")
          build_commands << "#{msbuild_arg} #{sln_arg} /p:Configuration=#{configuration} #{platform_arg}"
        end
      end
    end
    build_commands
  end
end

if defined?(DEBUG)
  puts
  puts "MSBuild"
  msb = MSBuild.new
  pp msb
  puts
end
