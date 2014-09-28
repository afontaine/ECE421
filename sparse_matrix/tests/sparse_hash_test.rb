require 'test/unit'
require 'matrix'
require 'contracts'
require_relative '../sparse_hash.rb'

class SparseHashTests < Test::Unit::TestCase
	def test_create
		size, default = 11, 0
		h = SparseHash.new(size, default)
		assert_equal(h.size, size)

		assert_equal(h[-1], default)
		assert_equal(h[0], default)
		assert_equal(h[size/2], default)		
		assert_equal(h[size-1], default)
		assert_nil(h[size])

		h[size/2] = 10
		assert_equal(h[size/2], 10)
	end

	def test_setters
		size, default = 11, 0
		h = SparseHash.new(size, default)

		h[size-1] = 10
		assert_equal(h[size-1], 10)

		h[size] = 10
		assert_nil(h[size])

		h["1"] = 10
		assert_equal(h["1"], 10)
		assert_equal(h[1], 10)
	end

	private
	def build_multihash(a)
		a.each_with_index.inject(SparseHash.new(a.size) { SparseHash.new(a[0].size, 0) }) do |h,(row,i)|
			row.each_with_index do |v,j|
				unless v == 0
					h[i] = h[i] unless h.has_key? i
					h[i][j] = v 
				end
			end
			h
		end
	end

	def multihash_to_a(h)
		Array.new(h.size) { |i| Array.new(h[i].size) { |j| h[i][j] } }
	end

end