#
# nunit dlls may be specified with
# NUNIT=FileList.new('**/*.Test.dll')
#
# for nunit dlls that must be run in x86 mode,
# NUNIT_x86=FileList.new('**/*.x86.Test.dll')
#
desc 'performs test commands'
task :test => [:build] do Tasks.execute_task :test;end

class Test < Array
	def update
		add_quiet 'rspec --format documentation' if File.exists?('spec')

		if(defined?(NUNIT))
			NUNIT.each{|nunit_dll|
				skip = false
				skip = true if(nunit_dll.include?('/netcoreapp')) 
				if(!skip)
					nunit_arg=Test.nunit_console
					nunit_arg="\"#{Test.nunit_console}\"" if Test.nunit_console.include?(' ')
					dll_arg=nunit_dll
					dll_arg="\"#{nunit_dll}\"" if(nunit_dll.include?(' '))
					if(Test.nunit_console.include?('nunit3'))
						xml_arg="--result=#{nunit_dll}.TestResults.xml --labels=All"
						xml_arg="--result=\"#{nunit_dll}.TestResults.xml\" --labels=All" if(nunit_dll.include?(' '))
					else
						xml_arg="/xml:#{nunit_dll}.TestResults.xml"
						xml_arg="/xml:\"#{nunit_dll}.TestResults.xml\"" if(nunit_dll.include?(' '))
						end
					add_quiet "#{nunit_arg} #{dll_arg} #{xml_arg}"
				end
			}
		end

		if(defined?(NUNIT_X86))
			NUNIT_X86.each{|nunit_dll|
				if(Test.nunit_console_x86.include?('nunit3'))
				  add_quiet "\"#{Test.nunit_console_x86}\" \"#{Rake.application.original_dir}\\#{nunit_dll}\" --result=\"#{nunit_dll}.TestResults.xml\" --labels=All"
				else
				  add_quiet "\"#{Test.nunit_console_x86}\" \"#{Rake.application.original_dir}\\#{nunit_dll}\" /xml:\"#{nunit_dll}.TestResults.xml\""
				end
			}
		end

		if(defined?(TESTS))
			TEST.each{|t| add_quiet t}
		end
	end

    def self.nunit3_console_in_path?
      command=Command.new('nunit3-console')
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      return true if(command[:exit_code] == 0) 
      false
    end

    def self.nunit_console_in_path?
      command=Command.new('nunit-console')
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      return true if(command[:exit_code] == 0) 
      false
    end
    @@nunit_console=''
	def self.nunit_console
		return "nunit3-console" if Test.nunit3_console_in_path?
		return "nunit-console" if Test.nunit_console_in_path?
		if(!File.exists?(@@nunit_console))
			if(defined?(NUNIT_CONSOLE))
				@@nunit_console = NUNIT_CONSOLE 
			end
			@@nunit_console = "packages/NUnit.ConsoleRunner.3.7.0/tools/nunit3-console.exe" if(!File.exists?(@@nunit_console))
			@@nunit_console = "packages/NUnit.ConsoleRunner.3.8.0/tools/nunit3-console.exe" if(!File.exists?(@@nunit_console))
			@@nunit_console = "C:\\Program Files (x86)\\NUnit.org\\nunit-console\\nunit3-console.exe" if(!File.exists?(@@nunit_console))
			@@nunit_console = "C:\\Program Files (x86)\\NUnit 2.6.4\\bin\\nunit-console.exe" if(!File.exists?(@@nunit_console))
			@@nunit_console = "C:\\Program Files (x86)\\NUnit 2.6.3\\bin\\nunit-console.exe" if(!File.exists?(@@nunit_console))
			if(!File.exists?(@@nunit_console))
				Dir.glob('**/nunit3-console.exe'){|n| @@nunit_console=n}
			end
		end
		if(!File.exists?(@@nunit_console))
			raise "unable to locate nunit-console.exe, assign NUNIT_CONSOLE to the correct location."
		end
		@@nunit_console
	end

	@@nunit_console_x86=''
	def self.nunit_console_x86
		if(!File.exists?(@@nunit_console_x86))
			if(defined?(NUNIT_CONSOLE_X86))
				@@nunit_console_x86 = NUNIT_CONSOLE_X86 
			end
			@@nunit_console_x86 = "C:\\Program Files (x86)\\NUnit.org\\nunit-console\\nunit3-console.exe" if(!File.exists?(@@nunit_console_x86))
			@@nunit_console_x86 = "C:\\Program Files (x86)\\NUnit 2.6.4\\bin\\nunit-console-x86.exe" if(!File.exists?(@@nunit_console_x86))
			@@nunit_console_x86 = "C:\\Program Files (x86)\\NUnit 2.6.3\\bin\\nunit-console-x86.exe" if(!File.exists?(@@nunit_console_x86))
		end
		if(!File.exists?(@@nunit_console_x86))
			raise "unable to locate nunit-console-x86.exe, assign NUNIT_CONSOLE_X86 to the correct location."
		end
		@@nunit_console_x86
	end
end

if !defined?(NUNIT)
	NUNIT=FileList.new('**/bin/**/*.Test.dll','**/bin/**/*.Tests.dll','**/lib/**/*.Test.dll','**/lib/**/*.Tests.dll')
end