require 'test/unit'
require 'thwait'

module ParallelMergeSort
  include Test::Unit::Assertions

  def self.sort(arr, &comparator)
    pre_sort(arr)
    comparator ||= ->(a,b) { a <=> b }
    spawn_thread(false) { psort(arr, &comparator) }.run
  end

  private
  def self.psort(arr, &comparator)
    return arr if arr.size <= 1
    middle = arr.size/2
    th_left = spawn_thread { psort(arr[0...middle], &comparator) }.run
    th_right = spawn_thread { psort(arr[middle...arr.size], &comparator) }.run
    pmerge(th_left.value, th_right.value, Array.new(arr.size, 0), 0, &comparator)
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
      j = binary_search(right, left[left.size/2], &comparator)
      th_left = spawn_thread { pmerge(left[0...left.size/2], right[0...j], result, cur_index, &comparator) }.run
      th_right = spawn_thread { pmerge(left[left.size/2...left.size], right[j...right.size], result, cur_index + left.size/2 + j, &comparator) }.run
      ThreadsWait.all_waits(th_left, th_right)
    end
    result
  end

  def self.binary_search(arr, x)
    ([*arr.each_with_index].bsearch { |y,_| yield(y, x) > 0 } || [nil, arr.size]).last
  end

  def self.pre_sort(arr)
    #assert arr.is_a? Array
  end

  def self.spawn_thread(add = true)
    th = Thread.new do 
      Thread.current[:children] ||= []
      begin
        yield
      ensure
        Thread.current[:children].each { |th| th.kill }
      end
    end

    Thread.current[:children] << th if add
    th
  end

end