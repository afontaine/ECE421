require 'test/unit'
require 'thwait'

module ParallelMergeSort
  include Test::Unit::Assertions

  def self.sort(arr, &comparator)
    pre_sort(arr)
    comparator ||= ->(a,b) { a <=> b }
    Thread.new { psort(arr, &comparator) }.run
  end

  private
  def self.psort(arr, &comparator)
    return arr if arr.size <= 1
    middle = arr.size/2
    th_left = Thread.new { psort(arr[0...middle], &comparator) }.run
    th_right = Thread.new { psort(arr[middle...arr.size], &comparator) }.run
    ThreadsWait.all_waits(th_left, th_right)
    result = Array.new(arr.size, 0) 
    pmerge(th_left.value, th_right.value, result, 0, &comparator)
    puts "#{result}"
    result
  end 

  def self.pmerge(left, right, result, cur_index, &comparator)
    if right.size > left.size
      return pmerge(right, left, result, cur_index, &comparator)
    elsif left.size + right.size == 1
      result[cur_index] = left[0]
    elsif left.size == 1 && right.size == 1
      if comparator.(left[0], right[0]) <= 0
        result[cur_index] = left[0]
        result[cur_index + 1] = right[0]
      else
        result[cur_index] = right[0] 
        result[cur_index + 1] = left[0]
      end
    else 
      j = find_index(right, left[left.size/2], &comparator)
      th_left = Thread.new { pmerge(left[0...left.size/2], right[0...j], result, cur_index, &comparator) }.run
      th_right = Thread.new { pmerge(left[left.size/2...left.size], right[j...right.size], result, cur_index + left.size/2 + j, &comparator) }.run
      ThreadsWait.all_waits(th_left, th_right)
    end
  end

  def self.binary_search(arr, x)
    j = ([*arr.each_with_index].bsearch { |y,_| yield(y, x) > 0 } || [nil, arr.size]).last - 1
    j = 0 if j < 0
    j
  end

  def self.find_index(arr, x)
    j = (arr.index { |y| yield(y, x) > 0 } || arr.size) - 1
    j = 0 if j < 0
    j
  end

  def self.pre_sort(arr)
    #assert arr.is_a? Array
  end

end