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
    pre_conditions
    invariants
  end

  def invariants
    assert_true(@empty_array.empty?)
  end

  def pre_conditions
    assert_true(ThreadedMergeSort.sort(@sorted_array).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_false(ThreadedMergeSort.sort(@backwards_array).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    invariants
  end

  def test_sort
    sorter = ThreadedMergeSort.sort(@arr)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@sorted_array)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@empty_array)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ThreadedMergeSort.sort(@backwards_array)
    assert_true(sorter.result.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  def test_cancel
    assert_raise(ThreadedMergeSort::CanceledError) do
      ThreadedMergeSort.sort(@arr).cancel
    end
  end
end