require 'shellwords'

# Pretty fly for a ruby... thing\
module AirShell


  class FileNotFoundError < ArgumentError;
  end

  class Pilot

    def initialize
      @history = []
      @variables = {}
    end

    def pipe(commands, input = nil)
      commands.split('|').reduce(input) do |data, e|
        run_command(e, data)
      end
    end

    def run_command(command, input = nil)
      IO::popen(command.split, 'w+') do |f|
        f.write(input) if input
        f.close_write
        f.read
      end
    end

    def file_out(file, data)
      File::open(file, 'w') do |f|
        f.write(data)
      end
    end

    def file_in(file)
      begin
        File::open(file) do |f|
          f.read
        end
      rescue Errno::ENOENT
        raise AirShell::FileNotFoundError, "#{file} was not found"
      end
    end

    def eval(commands)
      raise ArgumentError if commands.count('>') > 1
      raise ArgumentError if commands.count('<') > 1
      commands.strip!
      /< (?<f_in>\S+)/ =~ commands
      commands.gsub!(/< \S+/, '')
      /> (?<f_out>\S+)/ =~ commands
      commands.gsub!(/> \S+/, '')
      data = file_in(f_in) if f_in
      data = pipe(commands, data)
      if f_out
        file_out(f_out, data)
      else
        puts data
      end
    end

    def dir
      Dir.getwd
    end

    attr_accessor :history
  end

  def self.prompt
    "#{ENV['USER']}:8==D~ "
  end

  def self.change_dir(dir)
    Dir.chdir(dir)
  end

  def self.define_variable(line)
    /(?<var>\w+)\W*=\W*(?<val>\w+)/ =~ line
    VARIABLES[var.to_sym] = val if var
  end

  def self.replace_variables(line)
    line.gsub!(/\$(\w+)/) do |match|
      VARIABLES.key?($1.to_sym) ? VARIABLES[$1.to_sym] : $1
    end
  end

  def self.run_line(shell)
    print self.prompt
    line = gets.chomp
    self.eval(line, shell)
  end

  def self.eval(line, shell)
    line = line.to_s if line.respond_to?(:to_s)
    shell.history.push(line)
    self.replace_variables(line) if line.include?('$')
    self.define_variable(line) if line.include?('=')
    Kernel.exit if line == 'exit'
    command = line.split
    self.change_dir(command[1]) if command[0] == 'cd'
    begin
      shell.eval(line)
    rescue Errno::ENOENT
      puts "Command not found." unless command[0] == 'cd' || line == 'exit'
    rescue AirShell::FileNotFoundError => e
      puts e.message
    rescue ArgumentError
      puts 'Command was not properly formed.'
    end
  end

  def self.run
    pilot = AirShell::Pilot.new
    while 1
      run_line(pilot)
    end
  end
end
