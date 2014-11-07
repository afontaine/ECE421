require 'benchmark'
require 'test/unit'
require 'timeout'
require_relative 'data/parallel_merge_sort'

arr_10 = Array.new(10) { rand(100) }
arr_100 = Array.new(100) { rand(1000) }
arr_1000 = Array.new(1000) { rand(10000) }
already_sorted = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


puts "\nSorting small array (10)"
Benchmark.bm do |x|
  x.report("Built In:") { arr_10.sort }
  x.report("P-Merge-Sort:") { ParallelMergeSort.sort(arr_10, &:<=>).value }
end

puts "\nSorting medium array (100)"
Benchmark.bm do |x|
  x.report("Built In:") { arr_100.sort }
  x.report("P-Merge-Sort:") { ParallelMergeSort.sort(arr_100).value }
end

puts "\nSorting large array (1000)"
Benchmark.bm do |x|
  x.report("Built In:") { arr_1000.sort }
  x.report("P-Merge-Sort:") { ParallelMergeSort.sort(arr_1000).value }
end

puts "\nComparison"
puts "Built in sort: #{arr_10.sort}"
puts "P-Merge-Sort: #{ParallelMergeSort.sort(arr_10).value}"
puts "Original array: #{arr_10} still unchanged."

puts "\nTimeout of ~5 seconds"
begin
  ParallelMergeSort.timed_sort(arr_1000, 5)
rescue Timeout::Error
  puts "Timeout occured"
end