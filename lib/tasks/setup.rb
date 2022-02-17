# frozen_string_literal: true

desc "performs setup commands"
task :setup do Tasks.execute_task :setup; end

#
# use the SVN_EXPORTS hash to define svn exports destined for DEV_ROOT/dep
#
# SVN_EXPORT={ 'System.Data.SQLite/1.0.93.0' => 'https://third-party.googlecode.com/svn/trunk/System.Data.SQLite/1.0.93.0' }
#
class Setup < Array
  def initialize(value = nil)
    env = value if value.is_a? Environment
  end

  def update
    env = Environment.new if env.nil?
    add_quiet "bundle install" if File.exist? "Gemfile"

    Dir.glob("*.gemspec").each do |gemspec_file|
      add_quiet "<%Gemspec.update('#{gemspec_file}')%>"
    end

    if Dir.glob("**/packages.config").length.positive?
      Dir.glob("**/*.sln").each do |sln_file|
        add_quiet "nuget restore \"#{sln_file}\"" unless sln_file.include?("packages/")
      end
    else
      Dir.glob("**/*.sln").each do |sln_file|
        add_quiet "dotnet restore \"#{sln_file}\""
      end
    end

    add_quiet "dotnet restore" if File.exist?("project.json")

    # puts 'Setup checking SVN_EXPORTS...' if env.debug?
    if defined?(SVN_EXPORTS)
      SVN_EXPORTS.each do |k, v|
        dest = "#{Command.dev_root}/dep/#{k}"
        if !File.exist?(dest)
          puts "#{Command.dev_root}/dep/#{k} does not exists" if env.debug?
          FileUtils.mkdir_p(File.dirname(dest)) unless File.exist?(File.dirname(dest))
          unless dest.include?("@")
            puts "adding svn export #{v} #{dest}" if env.debug?
            add_quiet "svn export #{v} #{dest}"
          end
          if dest.include?("@")
            puts "adding svn export #{v} #{dest}@" if env.debug?
            add_quiet "svn export #{v} #{dest}@"
          end
          # add "svn export #{v} #{dest}" if !dest.include?("@")
          # add "svn export #{v} #{dest}@" if dest.include?("@")
        elsif env.debug?
          puts "#{Command.dev_root}/dep/#{k} exists."
        end
      end
    else
      # puts 'SVN_EXPORTS is not defined' if env.debug?
    end

    if defined?(GIT_EXPORTS)
      GIT_EXPORTS.each do |k, v|
        directory = "#{Command.dev_root}/dep/#{k}"
        unless File.exist?(directory)
          if v.include?("@")
            puts `git clone #{v.split("@")[0]} #{directory}`
            Dir.chdir(directory) do
              puts `git reset --hard #{v.split("@")[1]}`
            end
          else
            add_quiet "git clone #{v} #{directory}"
          end
        end
      end
    end

    if defined?(ZIP_EXPORTS)
      ZIP_EXPORTS.each do |k, v|
        # puts "Here: #{k} -> #{v}"
        directory = "#{Command.dev_root}/dep/#{k}"
        Zip.export(v, directory) unless Dir.exist?(directory)
      end
    end

    if defined?(VERSION)
      # puts "updating nuspec files for VERSION #{VERSION}" if env.debug?
      Dir.glob("*.nuspec").each do |nuspec|
        # current_version=IO.read(nuspec).scan(/<version>[\d.\w]+<\/version>/)[0]
        current_version = IO.read(nuspec).scan(%r{<version>[\d.\w-]+</version>})[0]
        next if current_version.nil?

        tag = ""
        if current_version.length > 1
          tag = IO.read(nuspec).scan(%r{<version>([\d.]+)([\w-]+)?</version>})[0][1]
          puts "pre-release tag #{tag}"
        else
          puts "no pre-release tag"
        end

        puts "#{nuspec} current version=#{current_version}" # if env.debug?
        next unless current_version.include?("<version>")

        target_version = "<version>#{VERSION}#{tag}</version>"
        if current_version != target_version
          add_quiet "<%Text.replace_in_file('#{nuspec}','#{current_version}','#{target_version}')%>"
        end
      end
      Dir.glob("**/AssemblyInfo.cs").each do |assemblyInfo|
        current_version = IO.read(assemblyInfo).scan(/Version\("[\d.]+"\)/)[0]
        next if current_version.nil?

        puts "#{assemblyInfo} current version=#{current_version}" if env.debug?
        next unless current_version.include?("Version(")

        target_version = "Version(\"#{VERSION}\")"
        if current_version != target_version
          add_quiet "<%Text.replace_in_file('#{assemblyInfo}','#{current_version}','#{target_version}')%>"
        end
      end
      Dir.glob("*.yml").each do |yml|
        puts "scanning #{yml} for version..." if defined?(DEBUG)
        current_version = IO.read(yml).scan(/v:\("[\d.]+"\)/)[0]
        puts "no version found in #{yml}" if current_version.nil?
        next if current_version.nil?

        puts "#{yml} current version=#{current_version}" if defined?(DEBUG)
        next unless current_version.include?("v:")

        target_version = "v:\"#{VERSION}\""
        if current_version != target_version
          add "<%Text.replace_in_file('#{yml}','#{current_version}','#{target_version}')%>"
        end
      end
      Dir.glob("**/*.csproj").each do |csproj|
        current_version = IO.read(csproj).scan(%r{<PackageVersion>[\d.]+</PackageVersion>})[0]
        unless current_version.nil?
          puts "#{csproj} current version=#{current_version}" if env.debug?
          if current_version.include?("<PackageVersion>")
            target_version = "<PackageVersion>#{VERSION}</PackageVersion>"
            if current_version != target_version
              add_quiet "<%Text.replace_in_file('#{csproj}','#{current_version}','#{target_version}')%>"
            end
          end
        end
        current_version = IO.read(csproj).scan(%r{<Version>[\d.]+</Version>})[0]
        next if current_version.nil?

        puts "#{csproj} current version=#{current_version}" if env.debug?
        next unless current_version.include?("<Version>")

        target_version = "<Version>#{VERSION}</Version>"
        if current_version != target_version
          add_quiet "<%Text.replace_in_file('#{csproj}','#{current_version}','#{target_version}')%>"
        end
      end
      Dir.glob("**/*.{wxs,_wxs}").each do |wxs|
        current_version = IO.read(wxs).scan(/\sVersion=["']([\d.]+)["']/)[0][0]
        puts "#{wxs} current version=#{current_version}" if env.debug?
        unless current_version.nil? # nclude?('Version='))
          target_version = VERSION # {}"Version=\"#{VERSION}\")="
          if current_version != target_version
            add_quiet "<%Text.replace_in_file('#{wxs}','#{current_version}','#{target_version}')%>"
          end
        end
      rescue StandardError
      end
    end
    log_debug_info("Setup")
  end

  def self.setupStandardClassLib(name, language)
    projectExtension = "csproj"
    projectExtension = "fsproj" if language == "F#"
    FileUtils.mkdir(name) unless Dir.exist?(name)
    unless File.exist?("#{name}/#{name}.#{projectExtension}")
      Dir.chdir(name) do
        puts `dotnet new classlib -lang #{language}`
      end
    end
    FileUtils.mkdir("#{name}.Test") unless Dir.exist?("#{name}.Test")
    unless File.exist?("#{name}.Test/#{name}.Test.#{projectExtension}")
      Dir.chdir("#{name}.Test") do
        puts `dotnet new nunit -lang #{language}`
        puts `dotnet add reference ../#{name}/#{name}.#{projectExtension}`
      end
    end
  end
end
