# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

require_relative('../base/environment')

desc 'performs build commands'
task :build do Tasks.execute_task :build; end

SLN_FILES = FileList.new('*.sln', '*/*.sln', '*/*/*.sln') unless defined?(SLN_FILES)

WXS_FILES = FileList.new('**/*.wxs')
SMARTASSEMBLY_FILES = FileList.new('**/*.saproj')

class Build < Array
  def update
    # puts "SLN_FILES: #{SLN_FILES}" if(Environment.default.debug?)

    update_gemspec
    update_dotnet
    update_sln if Environment.windows?
    update_smartassembly if Environment.windows?
    # update_nuget if Environment.windows?
    update_wix if Environment.windows? && !defined?(NO_WIX)
    update_xcode if Environment.mac?

    log_debug_info('Build') if defined?(DEBUG)
  end

  def update_gemspec
    # puts "Build scanning for gemspec files" if Environment.default.debug?
    Dir.glob('*.gemspec')  do |gemspec|
      add_quiet("gem build #{gemspec}") unless File.exist?(Gemspec.gemfile(gemspec))
    end
  end

  def update_dotnet
    # puts "Build scanning for project.json" if Environment.default.debug?
    add_quiet 'dotnet build' if File.exist?('project.json')
  end

  def update_sln
    # puts "Build scanning for sln files" if Environment.default.debug?
    SLN_FILES.each do |sln_file|
      puts "  #{sln_file}" if Environment.default.debug?
      build_commands = MSBuild.get_build_commands sln_file
      if !build_commands.nil?
        build_commands.each do |c|
          puts "  build command #{c} discovered." if Environment.default.debug?
          add_quiet(c)
        end
      elsif Environment.default.debug?
        puts '  no build command discovered.'
      end
    end
  end

  def update_smartassembly
    # puts "Build scanning for sa (smart assembly) files" if Environment.default.debug?
    sa = 'C:/Program Files/Red Gate/SmartAssembly 6/SmartAssembly.com'
    if File.exist?('C:/Program Files/Red Gate/SmartAssembly 7/SmartAssembly.com')
      sa = 'C:/Program Files/Red Gate/SmartAssembly 7/SmartAssembly.com'
    end
    SMARTASSEMBLY_FILES.each do |saproj_file|
      puts "  #{saproj_file}" if Environment.default.debug?
      if !File.exist?(sa)
        puts "warning: #{sa} does not exist, skipping build command for #{saproj_file}"
      else
        add_quiet("\"#{sa}\" /build #{saproj_file}")
      end
    end
  end

  def update_wix
    # puts "Build scanning for wxs <Product> files" if Environment.default.debug?
    WXS_FILES.each do |wxs_file|
      next unless IO.read(wxs_file).include?('<Product')

      build_commands = Wix.get_build_commands wxs_file
      next if build_commands.nil?

      build_commands.each do |c|
        add_quiet(c)
      end
    end

    # puts "Build scanning for wxs <Bundle> files" if Environment.default.debug?
    WXS_FILES.each do |wxs_file|
      next unless IO.read(wxs_file).include?('<Bundle')

      build_commands = Wix.get_build_commands wxs_file
      next if build_commands.nil?

      build_commands.each do |c|
        add_quiet(c)
      end
    end
  end

  def update_xcode
    # puts "Build scanning for xcodeproj folders" if Environment.default.debug?
    Dir.glob('**/*.xcodeproj').each do |dir|
      puts dir if Environment.default.debug?
      build_commands = XCodeBuild.get_build_commands dir
      next if build_commands.nil?

      build_commands.each do |c|
        build_commands << c
      end
    end
  end
end
