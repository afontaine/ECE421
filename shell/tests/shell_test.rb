require 'test/unit'
require 'tmpdir'
require_relative '../data/pilot_shell'

class ShellTest < Test::Unit::TestCase

  def setup
    @sh = PilotShell.new
    @dir = Dir.mktmpdir
    Dir.chdir(@dir)
  end

  def cleanup
    FileUtils.rm_rf @dir
  end

  def test_echo
    compare_commands 'echo HI'
  end

  def test_cd
    compare_commands "cd #{@dir}"
    assert_equal(@dir, @sh.dir)
  end

  def test_ls
    file = File.open('test1', 'w')
    file.close
    compare_commands 'ls'
    compare_commands "ls #{dir}"
    compare_commands 'ls -lh'
    compare_commands 'ls -l -h'
  end

  def test_pipes
    compare_commands 'echo test 1 > test'
    compare_commands 'echo test 2 >> test'
    compare_commands 'cat test'
    compare_commands 'cat test | wc -c'
  end

  def test_history
    commands = ['ls', 'ls -lh', 'echo test']
    commands.each { |cmd| @sh.eval(cmd) }
    assert_equal @sh.history, commands
  end

  def test_invalid
    command = 'invalid_command_that_will_never_run if it does then I hate you and your computer'

    assert_raise(PilotShell::Error::CommandNotFound) do
      @sh.eval(command)
    end

    command = '{ |cmd| !nv4Lid 5ynt4>< }'
    assert_raise(PilotShell::Error::CommandNotFound) do
      @sh.eval(command)
    end
  end

  def capture_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('','w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  def compare_commands(command)
    assert_equal(capture_stdout { @sh.eval(command) }, capture_stdout { `#{command}` })
  end

end