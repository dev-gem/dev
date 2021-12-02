# frozen_string_literal: true

#
# nunit dlls may be specified with
# NUNIT=FileList.new('**/*.Test.dll')
#
# for nunit dlls that must be run in x86 mode,
# NUNIT_x86=FileList.new('**/*.x86.Test.dll')
#
desc 'performs test commands'
task test: [:build] do Tasks.execute_task :test; end

class Test < Array
  def update
    add_quiet 'rspec --format documentation' if File.exist?('spec')

    if defined?(NUNIT)
      NUNIT.each do |nunit_dll|
        skip = false
        skip = true if nunit_dll.include?('/netcoreapp')
        skip = true if nunit_dll.include?('packages/')
        next if skip

        nunit_arg = Test.nunit_console
        nunit_arg = "\"#{Test.nunit_console}\"" if Test.nunit_console.include?(' ')
        dll_arg = nunit_dll
        dll_arg = "\"#{nunit_dll}\"" if nunit_dll.include?(' ')
        if Test.nunit_console.include?('nunit3')
          xml_arg = "--result=#{nunit_dll}.TestResults.xml --labels=All"
          xml_arg = "--result=\"#{nunit_dll}.TestResults.xml\" --labels=All" if nunit_dll.include?(' ')
        else
          xml_arg = "/xml:#{nunit_dll}.TestResults.xml"
          xml_arg = "/xml:\"#{nunit_dll}.TestResults.xml\"" if nunit_dll.include?(' ')
        end
        add_quiet "#{nunit_arg} #{dll_arg} #{xml_arg}"
      end
    end

    if defined?(NUNIT_X86)
      NUNIT_X86.each do |nunit_dll|
        if Test.nunit_console_x86.include?('nunit3')
          add_quiet "\"#{Test.nunit_console_x86}\" \"#{Rake.application.original_dir}\\#{nunit_dll}\" --result=\"#{nunit_dll}.TestResults.xml\" --labels=All"
        else
          add_quiet "\"#{Test.nunit_console_x86}\" \"#{Rake.application.original_dir}\\#{nunit_dll}\" /xml:\"#{nunit_dll}.TestResults.xml\""
        end
      end
    end

    # dotnet test
    puts 'scanning for **/*.Test.csproj' if Environment.default.debug?
    Dir.glob('**/*.Test.csproj') do |proj|
      puts "found #{proj}" if Environment.default.debug?
      text = IO.read(proj)
      add_quiet("dotnet test #{proj}") if text.include?('netcoreapp')
    end

    TEST.each { |t| add_quiet t } if defined?(TESTS)
  end

  def self.nunit3_console_in_path?
    command = Command.new('nunit3-console')
    command[:quiet] = true
    command[:ignore_failure] = true
    command.execute
    return true if (command[:exit_code]).zero?

    false
  end

  def self.nunit_console_in_path?
    command = Command.new('nunit-console')
    command[:quiet] = true
    command[:ignore_failure] = true
    command.execute
    return true if (command[:exit_code]).zero?

    false
  end
  @@nunit_console = ''
  def self.nunit_console
    return 'nunit3-console' if Test.nunit3_console_in_path?
    return 'nunit-console' if Test.nunit_console_in_path?

    unless File.exist?(@@nunit_console)
      @@nunit_console = NUNIT_CONSOLE if defined?(NUNIT_CONSOLE)
      unless File.exist?(@@nunit_console)
        @@nunit_console = 'packages/NUnit.ConsoleRunner.3.7.0/tools/nunit3-console.exe'
      end
      unless File.exist?(@@nunit_console)
        @@nunit_console = 'packages/NUnit.ConsoleRunner.3.8.0/tools/nunit3-console.exe'
      end
      unless File.exist?(@@nunit_console)
        @@nunit_console = 'C:\\Program Files (x86)\\NUnit.org\\nunit-console\\nunit3-console.exe'
      end
      unless File.exist?(@@nunit_console)
        @@nunit_console = 'C:\\Program Files (x86)\\NUnit 2.6.4\\bin\\nunit-console.exe'
      end
      unless File.exist?(@@nunit_console)
        @@nunit_console = 'C:\\Program Files (x86)\\NUnit 2.6.3\\bin\\nunit-console.exe'
      end
      Dir.glob('**/nunit3-console.exe') { |n| @@nunit_console = n } unless File.exist?(@@nunit_console)
    end
    unless File.exist?(@@nunit_console)
      raise 'unable to locate nunit-console.exe, assign NUNIT_CONSOLE to the correct location.'
    end

    @@nunit_console
  end

  @@nunit_console_x86 = ''
  def self.nunit_console_x86
    unless File.exist?(@@nunit_console_x86)
      @@nunit_console_x86 = NUNIT_CONSOLE_X86 if defined?(NUNIT_CONSOLE_X86)
      unless File.exist?(@@nunit_console_x86)
        @@nunit_console_x86 = 'C:\\Program Files (x86)\\NUnit.org\\nunit-console\\nunit3-console.exe'
      end
      unless File.exist?(@@nunit_console_x86)
        @@nunit_console_x86 = 'C:\\Program Files (x86)\\NUnit 2.6.4\\bin\\nunit-console-x86.exe'
      end
      unless File.exist?(@@nunit_console_x86)
        @@nunit_console_x86 = 'C:\\Program Files (x86)\\NUnit 2.6.3\\bin\\nunit-console-x86.exe'
      end
    end
    unless File.exist?(@@nunit_console_x86)
      raise 'unable to locate nunit-console-x86.exe, assign NUNIT_CONSOLE_X86 to the correct location.'
    end

    @@nunit_console_x86
  end
end

unless defined?(NUNIT)
  NUNIT = FileList.new('**/bin/**/*.Test.dll', '**/bin/**/*.Tests.dll', '**/lib/**/*.Test.dll',
                       '**/lib/**/*.Tests.dll')
end
