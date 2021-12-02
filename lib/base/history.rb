# frozen_string_literal: true

puts __FILE__ if defined?(DEBUG)

class History
  attr_accessor :dev

  def initialize(dev = nil)
    @dev = dev
    @dev = Dev.new if @dev.nil?
  end

  # .0. for 0 exit codes
  # .X. for non 0 exit codes
  # project name is contained in directory name
  def get_commands(pattern)
    commands = []
    Dir.chdir(@dev.log_dir) do
      Dir.glob("*#{pattern.gsub('/', '-')}*.*").each do |logfile|
        commands << Command.new(JSON.parse(IO.read(logfile)))
      end
    end
    commands
  end

  def add_command(command)
    code = '0'
    code = 'X' if command[:exit_code] != 0
    directory = command[:directory].gsub(@dev.root_dir, '').gsub('/', '-')
    name = "#{command[:input]}.#{code}.#{directory}.json"
    filename = "#{@dev.log_dir}/#{name}"
    puts "add command #{filename}" if @dev.debug?
    File.open(filename, 'w') { |f| f.write(command.to_json) }
  end

  def get_wrk_command(project_fullname)
    commands = get_commands(project_fullname.to_s.gsub('/', '-'))
    return commands[0] if commands.length.positive?

    nil
  end
end
