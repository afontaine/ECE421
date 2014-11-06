require 'test/unit'
require_relative '../data/parallel_merge_sort'

class SortTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    #@arr = Array.new(100) { rand(100) }
    @arr = [5, 6, 8, 3, 1, 9, 3, -2, 4, 7]
    @sorted_array = [1, 2, 3, 4, 5]
    @empty_array = []
    @backwards_array = [4, 3, 2, 1]
    @sorter = Proc.new do |x, y|
      x <=> y
    end
    @reverse_sorter = Proc.new do |x, y|
      y <=> x
    end
    #pre_conditions
    #invariants
  end

  def invariants
    assert_true(@empty_array.empty?)
  end

  def pre_conditions
    assert_true(ParallelMergeSort.sort(@sorted_array, &@sorter).value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    assert_false(ParallelMergeSort.sort(@backwards_array, &@sorter).value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    invariants
  end

  def test_sort
    sorter = ParallelMergeSort.sort(@arr, &@sorter).value
    assert_equal @arr.sort, sorter
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ParallelMergeSort.sort(@sorted_array, &@sorter)
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ParallelMergeSort.sort(@empty_array, &@sorter)
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
    sorter = ParallelMergeSort.sort(@backwards_array, &@sorter)
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end

  def test_cancel
    ParallelMergeSort.sort(@arr, &@sorter).kill
  end

  def test_block
    sorter = ParallelMergeSort.sort(@arr, &@reverse_sorter)
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[1] <=> val[0]) <= 0)
    end)

    sorter = ParallelMergeSort.sort(@arr) { |x, y| x <=> y }
    assert_true(sorter.value.each_cons(2).reduce(true) do |result, val|
      result && ((val[0] <=> val[1]) <= 0)
    end)
  end
end