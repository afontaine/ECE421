require 'test/unit'
require_relative '../data/threaded_merge_sort'

class SortTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @arr = Array.new(100) { rand }
    @sorted_array = [1, 2, 3, 4, 5]
    @empty_array = []
    @backwards_array = [4, 3, 2, 1]
    @sorter = Proc.new do |x, y|
      x <=> y
    end
    @reverse_sorter = Proc.new do |x, y|
      y <=> x
    end
    pre_conditions
    invariants
  end

  def invariants
    assert_true(@empty_array.empty?)
  end

  def pre_conditions
    assert_true(ThreadedMergeSort.sort(@sorted_array, 5000, &@sorter).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_false(ThreadedMergeSort.sort(@backwards_array, 5000, &@sorter).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    invariants
  end

  def test_sort
    sorter = ThreadedMergeSort.sort(@arr, 5000, &@sorter)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@sorted_array, 5000, &@sorter)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@empty_array, 5000, &@sorter)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@backwards_array, 5000, &@sorter)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  def test_cancel
    assert_raise(ThreadedMergeSort::CanceledError) do
      ThreadedMergeSort.sort(@arr, 5000, &@sorter).cancel
    end
  end

  def test_block
    sorter = ThreadedMergeSort.sort(@arr, 5000, &@reverse_sorter)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[1] <=> val[0]) <= 0)
    end)

    sorter = ThreadedMergeSort.sort(@arr, 5000) { |x, y| x <=> y }
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  def test_timeout
    assert_raise(ThreadedMergeSort::TimeoutError) do
      ThreadedMergeSort.sort(@arr, 1, &@sorter)
    end
  end
end