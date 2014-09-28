require 'test/unit'
require 'matrix'
require_relative '../sparse_matrix.rb'

class SparseMatrixTests < Test::Unit::TestCase
	def test_to_a
		a = [
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]

		sm = SparseMatrix.rows(a)
		assert_equal(sm.to_a, a)
	end

	def test_create
		sm = SparseMatrix[]
		assert_equal(sm.to_a, [])

		a = [
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]

		sm = SparseMatrix.rows(a)
		m = Matrix.rows(a)

		assert_not_nil(sm)
		assert_equal(sm.to_a, m.to_a)
		assert_true(sm.square?)
		assert_false(sm.empty?)

		a = [
			[1,0,0,0],
			[0,0,0,0],
			[-9,0,0,0],
			[0,0,100,0],
			[0,0,0,0]
		]

		sm = SparseMatrix.rows(a)
		m = Matrix.rows(a)

		assert_not_nil(sm)
		assert_equal(sm.to_a, m.to_a)
		assert_false(sm.square?)
		assert_false(sm.empty?)

		assert_raise(Matrix::ErrDimensionMismatch) do
			SparseMatrix[
				[1,0,0,0,0],
				[0,0,0,0,0],
				[-9,0,0,0],
				[0,0,100,0,0],
				[0,0,0,0,99]
			]
		end
	end

	def test_transpose
		a = [
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]

		sm = SparseMatrix.rows(a)

		assert_equal(sm.transpose.to_a, a.transpose)

		a = [
			[1,0,0,0],
			[0,0,0,0],
			[-9,0,0,0],
			[0,0,100,0],
			[0,0,0,0]
		]

		sm = SparseMatrix.rows(a)

		assert_equal(sm.transpose.to_a, a.transpose)
	end

	def test_accessors
		sm = get_test_matrix

		a = sm.to_a
		assert_equal(sm.row_count, 5)
		sm.row_count.times do |i|
			assert_equal(sm.row(i), Vector.elements(a[i]))
		end

		assert_nil(sm.row(sm.row_count))
		assert_equal(sm.row(-1), sm.row(sm.row_count-1))

		a = a.transpose
		assert_equal(sm.column_count, 5)
		sm.column_count.times do |j|
			assert_equal(sm.column(j), Vector.elements(a[j]))
		end

		assert_nil(sm.column(sm.column_count))
		assert_equal(sm.column(-1), sm.column(sm.column_count-1))
	end

	private
	def get_test_matrix
		SparseMatrix[
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]
	end

end