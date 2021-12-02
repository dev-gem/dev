# frozen_string_literal: true

# COMMANDS[:build]=['xcodebuild clean -scheme Hydrogen -destination "name=iPhone 6"',
#                    'xcodebuild build -scheme Hydrogen -destination "name=iPhone 6"']
#  COMMANDS[:test]=['xcodebuild test -scheme Hydrogen -destination "name=iPhone 6"'] if RUBY_PLATFORM.include?('darwin')

class XCodeBuild < Hash
  def self.get_build_commands(xcodeproj_filename)
    # build_commands=Array.new
    # build_command=Command.new('xcodebuild build')
    # build_command[:directory] = File.dirname(xcodeproj_filename)

    # name=xcodeproj_filename.gsub('.xcodeproj','')
    # build_commands << "xcodebuild clean -scheme #{name} -destination \"name=iPhone 6\""
    # build_commands << "xcodebuild build -scheme #{name} -destination \"name=iPhone 6\""
    # build_commands << build_command
  end
end
