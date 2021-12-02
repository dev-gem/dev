# frozen_string_literal: true

if defined?(DEBUG)
  puts DELIMITER
  puts __FILE__
  puts
  puts 'nuget not found' unless Command.executes?('nuget')
  puts
end
# puts DELIMITER if defined?(DEBUG)
# puts __FILE__ if defined?(DEBUG)

class Nuget
  def self.get_build_commands(nuspec_file)
    build_commands = nil
    if File.exist?(nuspec_file)
      build_commands = [] if build_commands.nil?
      build_commands << if defined?(INCLUDE_REFERENCED_PROJECTS)
                          "nuget pack #{nuspec_file} -IncludeReferencedProjects"
                        else
                          "nuget pack #{nuspec_file}"
                        end
    end
    build_commands
  end

  def self.get_versions(filename)
    versions = {}
    if filename.include?('.nuspec')
      nuspec_text = File.read(filename, encoding: 'UTF-8')
      nuspec_text.scan(/<dependency\s+id="([\w.]+)"\s+version="([\d.]+[-\w]+)"/).each do |row|
        versions[row[0]] = row[1]
      end
      return versions
    end
    if filename.include?('packages.config')
      config_text = File.read(filename, encoding: 'UTF-8')
      config_text.scan(/<package\s+id="([\w.]+)"\s+version="([\d.]+[-\w]+)"/).each do |row|
        versions[row[0]] = row[1]
      end
      return versions
    end
    if filename.include?('.csproj')
      config_text = File.read(filename, encoding: 'UTF-8')
      config_text.scan(/<PackageReference\s+Include="([\w.]+)"\s+Version="([\d.]+[-\w]+)"/).each do |row|
        versions[row[0]] = row[1]
      end
      return versions
    end
    versions
  end

  def self.set_versions(filename, versions)
    text = File.read(filename, encoding: 'UTF-8')
    text_versions = text.scan(/id="[\w.]+"\s+version="[\d.]+[-\w]+"/)
    text2 = text
    versions.each do |k, v|
      text_versions.each do |line|
        if line.include?("\"#{k}\"")
          new_line = "id=\"#{k}\" version=\"#{v}\""
          text2 = text2.gsub(line, new_line)
        end
      end
    end
    File.open(filename, 'w') { |f| f.puts text2 } unless text == text2
  end

  def self.update_versions(source_filename, destination_filename)
    old_versions = Nuget.get_versions(destination_filename)
    source_versions = Nuget.get_versions(source_filename)
    new_versions = {}
    old_versions.each do |k, _v|
      new_versions[k] = source_versions[k] if source_versions.key?(k)
    end
    Nuget.set_versions(destination_filename, new_versions)
  end
end
