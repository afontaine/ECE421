require 'test/unit'
require 'tmpdir'
require_relative '../data/file_watch'

class FileWatchTest < Test::Unit::TestCase

  def setup
    @dir = Dir.mktmpdir
    @old_dir = Dir.pwd
    assert Dir["#{@dir}/*"].empty?
    Dir.chdir(@dir)
  end

  def cleanup
    Dir.chdir(@old_dir)
    FileUtils.rm_r @dir
  end

  def test_create_single
    block_ran = false

    watch = FileWatch.new(:create, 100, 'tmpfile') do |file_name|
      assert_equal file_name, 'tmpfile'
      block_ran = true
    end
    watch.run_async

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files, %w(tmpfile)

    sleep(0.5)
    File.open('tmpfile', 'w').close
    sleep(0.5)
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
    watch.run_async

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files, files

    sleep(0.5)
    files.each { |file| File.open(file, 'w').close }
    sleep(0.5)

    assert_equal block_run_count, 3
    assert_equal file_names, files
  end

  def test_invalid_input
    assert_raise(Test::Unit::AssertionFailedError) do
      FileWatch.new(Object.new, Object.new)
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      FileWatch.new(Object.new, Object.new, Object.new)
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      FileWatch.new(:create, 100)
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      FileWatch.new(:update, 100)
    end

    assert_raise(Test::Unit::AssertionFailedError) do
      FileWatch.new(:delete, 100)
    end
  end

  def test_coercion
    block_ran = false

    o = Object.new

    def o.to_sym;
      :create;
    end

    o2 = Object.new

    def o2.to_int;
      100;
    end

    o3 = Object.new

    def o3.to_s;
      'tmpfile';
    end

    watch = FileWatch.new(o, o2, o3) do |file_name|
      assert_equal file_name, 'tmpfile'
      block_ran = true
    end
    watch.run_async

    assert_equal watch.mode, :create
    assert_equal watch.delay, 100
    assert_equal watch.files.size, 1
    assert_equal watch.files[0], 'tmpfile'

    sleep(0.5)
    File.open('tmpfile', 'w').close
    sleep(0.5)

    assert block_ran
  end

  def test_update
    block_ran = false
    files = %w(test test1 test2)
    files.each { |f| File.open(f, 'w').close }

    watch = FileWatch.new(:update, 100, *files) do |file|
      assert file.include?('test')
      block_ran = true
    end
    watch.run_async

    assert_equal(:update, watch.mode)
    assert_equal(100, watch.delay)
    assert_equal(3, watch.files.size)
    assert watch.files.all? { |file| file.include?('test') }

    assert_false(block_ran)

    sleep(0.5)
    `echo 'test' > test`
    sleep(0.5)
    assert block_ran

    block_ran = false
    assert_false(block_ran)

    sleep(0.5)
    `echo 'test2' > test2`
    sleep(0.5)

    assert block_ran
  end

  def test_delete
    block_ran = false
    files = %w(test test1 test2)
    files.each { |f| File.open(f, 'w').close }
    watch = FileWatch.new(:delete, 100, *files) do |file|
      assert file.include?('test')
      block_ran = true
    end
    watch.run_async

    assert_equal(:delete, watch.mode)
    assert_equal(100, watch.delay)
    assert_equal(3, watch.files.size)
    assert watch.files.all? { |file| file.include?('test') }

    assert_false(block_ran)
    sleep(0.5)
    `rm test`
    sleep(0.5)
    assert block_ran

    block_ran = false
    assert_false(block_ran)
    sleep(0.5)
    `rm test2`
    sleep(0.5)
    assert block_ran
  end
end