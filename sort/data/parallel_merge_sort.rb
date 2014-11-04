require 'test/unit'

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
    middle = arr.size / 2
    left = Thread.new { psort(arr[0...middle], &comparator) }.run
    right = Thread.new { psort(arr[middle...arr.size], &comparator) }.run
    pmerge(left.value, right.value, [], &comparator)
  end

  def self.pmerge(a, b, c, &comparator)
    if b.size > a.size
      pmerge(b, a, c, &comparator)
    elsif c.size == 1
      c[0] = a[0]
    elsif a.size == 1 && b.size == 1
      if yield(a[0], b[0]) <= 0
        c[0] = a[0]
        c[1] = b[0]
      else
        c[0] = b[0]
        c[1] = a[0]
      end
    else
      j = [*b.each_with_index].bsearch { |x,_| x <= a[a.size/2] }.last
      left = Thread.new { pmerge(a[0...a.size/2], b[0...j], c[0...(a.size/2 + j)], &comparator) }.run
      right = Thread.new { pmerge(a[(a.size/2 + 1)...a.size], b[(j+1)...b.size], c[(a.size/2 + j + 1)...c.size], &comparator) }.run
      c += left.value + right.value
    end
    c
  end

  def self.pre_sort(arr)
    #assert arr.is_a? Array
  end

end