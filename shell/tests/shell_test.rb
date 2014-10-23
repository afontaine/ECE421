require 'test/unit'
require 'tmpdir'
require 'stringio'
require 'pry'
require_relative '../data/air_shell'

class ShellTest < Test::Unit::TestCase

  def setup
    @dir = Dir.mktmpdir
    Dir.chdir(@dir)
    @sh = AirShell::Pilot.new
    invariant
  end

  def cleanup
    invariant
    FileUtils.rm_rf @dir
  end

  def invariant
    assert !@sh.dir.empty?
  end

  def test_echo
    compare_commands 'echo HI'
  end

  def test_cd
    Dir.mkdir("test")
    AirShell.eval("cd test", @sh)
    assert_equal(@dir + "/test", @sh.dir)
  end

  def test_ls
    file = File.open('test1', 'w')
    file.close
    compare_commands 'ls'
    compare_commands "ls #{@dir}"
    compare_commands 'ls -lh'
    compare_commands 'ls -l -h'
  end

  def test_pipes
    compare_commands 'echo test 1 > test'
    # compare_commands 'cat test'
    # compare_commands 'cat test | wc -c'
  end

  def test_history
    commands = ['ls', 'ls -lh', 'echo test']
    commands.each { |cmd| AirShell.eval(cmd, @sh) }
    assert_equal @sh.history, commands
  end

  def test_invalid
    assert_equal(capture_stdout { AirShell.eval('invalid_command_that_will_never_run if it does then I hate you and your computer', @sh) }, "Command not found.\n")

    assert_equal(capture_stdout { AirShell.eval('{ |cmd| !nv4Lid 5ynt4>< }', @sh) }, "} was not found\n")

    assert_equal(capture_stdout { AirShell.eval(Object.new, @sh) }, "Command not found.\n")
  end

  def test_object
    o = Object.new

    def o.to_s;
      'ls';
    end

    compare_commands o
  end

  def capture_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('', 'w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  def compare_commands(command)
    assert_equal(capture_stdout { AirShell.eval(command, @sh) }, capture_stdout { puts `#{command}` })
  end

end
