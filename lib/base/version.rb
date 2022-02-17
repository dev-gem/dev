# frozen_string_literal: true

class Version
  def self.extract(text)
    [/VERSION\s*=\s*['"]([\d.]+)['"]/,
     /[Vv]ersion\s*=\s*['"]([\d.]+)['"]/,
     /Version\(\s*"([\d.]+)"\s*\)/].each do |regex|
      scan = text.scan(regex)
      return scan[0][0] if !scan.nil? && (scan.length.positive? && !scan[0].nil? && scan[0].length.positive?)
    end
    nil
  end

  def self.extract_from_file(filename)
    Version.extract IO.read(filename)
  end

  def self.extract_from_filelist(filelist)
    version = nil
    filelist.each do |f|
      version = extract_from_file f
      return version unless version.nil?
    end
    nil
  end

  def self.update_text(text, version)
    text = text.gsub(/version\s*=\s*'[\d.]+'/, "version='#{version}'")
    text = text.gsub(/VERSION\s*=\s*'[\d.]+'/, "VERSION='#{version}'")
    text = text.gsub(/version\s*=\s*"[\d.]+"/, "version=\"#{version}\"")
    text = text.gsub(/Version\s*=\s*'[\d.]+'/, "Version='#{version}'")
    text = text.gsub(/Version\s*=\s*"[\d.]+"/, "Version=\"#{version}\"")
    text = text.gsub(/Version\(\s*"[\d.]+"\s*\)/, "Version(\"#{version}\")")
    text = text.gsub(/Name\s*=\s*"Version"\s*Value\s*=\s*"[\d.]+"/, "Name=\"Version\" Value=\"#{version}\"")
  end

  def self.update_file(filename, version)
    if File.exist?(filename)
      orig = IO.read(filename)
      text = Version.update_text orig, version
      File.open(filename, "w") { |f| f.write(text) } if orig != text
    end
  end

  def self.update_filelist(filelist, version)
    filelist.each do |f|
      Version.update_file f, version
    end
  end

  def self.read(filename)
    return Gem::Specification.load(filename).version.to_s if filename.include?(".gemspec")

    if filename.include?("AssemblyInfo.cs")
      scan = IO.read(filename).scan(/Version\("([\d.]+)"\)/)
      return scan[0][0] if !scan.nil? && (scan.length.positive? && !scan[0].nil? && scan[0].length.positive?)

      # return IO.read(filename).scan(/Version\(\"([\d.]+)\"\)/)[0][0]
      scan = IO.read(filename).scan(/Version="([\d.]+)"/)
      return scan[0][0] if !scan.nil? && (scan.length.positive? && !scan[0].nil? && scan[0].length.positive?)
    end
    "0.0"
  end

  def self.get_version
    Dir.glob("**/*.gemspec").each do |gemspec|
      return Version.read gemspec
    end
    Dir.glob("**/AssemblyInfo.cs").each do |assemblyInfo|
      return Version.read assemblyInfo
    end
    Dir.glob("**/*.wxs").each do |wxs|
      return Version.read wxs
    end
    "0.0"
  end
end

VERSION = Version.get_version unless defined?(VERSION)
