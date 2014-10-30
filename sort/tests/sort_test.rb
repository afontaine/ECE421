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
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_sort
    assert_true(ThreadedMergeSort.sort(@arr).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_true(ThreadedMergeSort.sort(@sorted_array).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_true(ThreadedMergeSort.sort(@empty_array).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_true(ThreadedMergeSort.sort(@backwards_array).each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end
end