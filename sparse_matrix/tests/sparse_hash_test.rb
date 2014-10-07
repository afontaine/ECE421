require 'test/unit'
require_relative '../sparse_matrix.rb'

class SparseHashTests < Test::Unit::TestCase
	def setup
		@h1 = build_hash([10,5,0,0,0,9,-5,0,9,0], 0)

		@h2 = build_multi_hash([
			[2, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0],
			[0, 0, 0, 3, 0, 0],
			[0, 0, 0, 0, 0, 0],
			[0, -4, 0, 0, 0, 0],
			[0, 0, 0, 0, 1, 0]
		])

		@h3 = build_multi_hash([
			[2, 0, 0, 0, 0],
			[0, 0, 0, 0, 0],
			[0, 0, 0, 3, 0],
			[0, 0, 0, 0, 0],
			[0, -4, 0, 0, 0],
			[0, 0, 0, 0, 1]
		])

		@h4 = build_multi_hash([
			[2, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0],
			[0, 0, 0, 3, 0, 0],
			[0, 0, 0, 0, 0, 0],
			[0, -4, 0, 0, 0, 0]
		])
	end


	def test_create
		size, default = 11, 0
		h = SparseHash.new(size, default)
		assert_equal(h.size, size)

		assert_equal(h[-1], default)
		assert_equal(h[0], default)
		assert_equal(h[size/2], default)		
		assert_equal(h[size-1], default)
		assert_nil(h[size])
		assert_nil(h[size*-1 - 1])

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

	def test_defaults
		assert_true(@h1.has_key?(1))
		assert_equal(@h1[1], 5)
		assert_false(@h1.has_key?(2))
		assert_equal(@h1[2], 0)

		assert_true(@h1.has_key?(1))
		assert_equal(@h1[1], 5)
		assert_false(@h1.has_key?(2))
		assert_equal(@h1[2], 0)

	end

	def test_to_a
		assert_equal(@h1.to_a, [10,5,0,0,0,9,-5,0,9,0])

	end

	private

	def build_hash(a, default)
		a.each_with_index.inject(SparseHash.new(a.size, default)) do |h,(v,i)|
			h[i] = v
			h
		end
	end


	def build_multi_hash(a)
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

end