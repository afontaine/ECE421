require 'benchmark'
require 'test/unit'
require_relative 'data/parallel_merge_sort'

arr = [4, -5, -7, 4, 9, 0, 7, 2, 8, 3]
already_sorted = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
large_arr = Array.new(1000) { rand(10000) }

puts "Sorting small array (10)"
Benchmark.bm do |x|
  x.report("Built In:") { arr.sort }
  x.report("P-Merge-Sort:") { ParallelMergeSort.sort(arr).value }
  x.report("P-Merge-Sort-Reverse") { ParallelMergeSort.sort(arr) { |x,y| y <=> x }.value }
end

puts "Sorting large array (1000)"
Benchmark.bm do |x|
  x.report("Built In:") { large_arr.sort }
  x.report("P-Merge-Sort:") { ParallelMergeSort.sort(large_arr).value }
end

puts "Comparison"
puts "Built in sort: #{arr.sort}"
puts "P-Merge-Sort: #{ParallelMergeSort.sort(arr).value}"
