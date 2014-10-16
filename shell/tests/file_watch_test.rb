require 'test/unit'
require 'tmpdir'

class FileWatchTest < Test::Unit::TestCase

  def setup
    @dir = Dir.mktmpdir
    Dir.chdir(@dir)
  end

  def cleanup
    FileUtils.rm_rf @dir
  end

  def test_create
    block_ran = false

    watch = FileWatch.new(:create, 100, 'tmpfile') do |file_name|
      assert_equal file_name, 'tmpfile'
      block_ran = true
    end

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files.size, 1
    assert_equal watch.files[0], 'tmpfile'

    file = File.create('tmpfile', 'w')
    file.close
    sleep(100)
    assert block_ran
  end

end