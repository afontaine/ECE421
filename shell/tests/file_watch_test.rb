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

  def test_update
    block_ran = false
    `touch test test1 test2`
    watch = FileWatch(:update, `ls`.split(/\s+/), 100) do |file|
      assert_true(file.include?('test'))
    end

    assert_equal(:update, watch.mode)
    assert_equal(100, watch.delay)
    assert_equal(3, watch.files.size)
    assert_true(watch.files.all? { |file| file.include?('test') })

    assert_false(block_ran)
    `cat 'test' > test`
    sleep(105)
    assert_true(block_ran)

    block_ran = false
    assert_false(block_ran)
    `cat 'test2' > test2`
    sleep(105)
    assert_true(block_ran)
  end
end