require 'test/unit'
require 'tmpdir'
require_relative '../data/file_watch'

class FileWatchTest < Test::Unit::TestCase

  def setup
    @dir = Dir.mktmpdir
    Dir.chdir(@dir)
  end

  def cleanup
    FileUtils.rm_rf @dir
  end

  def test_create_single
    block_ran = false

    watch = FileWatch.new(:create, 100, 'tmpfile') do |file_name|
      assert_equal file_name, 'tmpfile'
      block_ran = true
    end

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files, %w(tmpfile)

    File.open('tmpfile', 'w').close
    sleep(200)
    assert block_ran
  end

  def test_create_multiple
    files = %w(file1 file2 file3)
    file_names = []
    block_run_count = 0
    watch = FileWatch.new(:create, 100, *files) do |file_name|
      file_names << file_name
      block_run_count += 1
    end

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files, files

    files.each { |file| File.open('tmpfile', 'w').close }

    sleep(200)
    assert_equal block_run_count, 3
    assert_equal file_names, files
  end

  def test_create_invalid
    assert_raise(ArgumentError) do
      FileWatch.new(Object.new, Object.new)
    end

    assert_raise(ArgumentError) do
      FileWatch.new(Object.new, Object.new, Object.new)
    end

    assert_raise(ArgumentError) do
      FileWatch.new(:create, 100)
    end
  end

  def test_create_coercion
    block_ran = false

    o = Object.new
    def o.to_s; 'create'; end

    o2 = Object.new
    def o2.to_i; 100; end

    o3 = Object.new
    def o3.to_s; 'tmpfile'; end

    watch = FileWatch.new(o, o2, o3) do |file_name|
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