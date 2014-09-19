require 'test/unit'
require 'matrix'
require_relative '../tridiagonal_matrix'

class TridiagonalMatrixFactoryTest < Test::Unit::TestCase
	def test_create
		m = TridiagonalMatrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		rm = Matrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		s = Vector[1, 2, 3, 4, 5, 6]

		assert_not_nil(m)
		assert_true(m.square?)
		assert_equal(m.determinant, rm.determinant)
		assert_equal(m.solve(s), rm.lup.solve(s))


		assert_raise(TridiagonalMatrix::ErrDimensionMismatch) do
			TridiagonalMatrix[
				[2, 3, 0, 0, 0, 0],
				[1, 2, 3, 0, 0, 0],
				[0, 1, 2, 3, 0, 0],
				[0, 0, 1, 2, 3, 0],
				[0, 0, 0, 1, 2, 3],
				[0, 0, 0, 0, 1, 2],
				[0, 0, 0, 0, 0, 1]
			]
		end
		
		assert_raise(TridiagonalMatrix::ErrNotTridiagonal) do
			TridiagonalMatrix[
				[2, 3, 0, 0, 0, 0],
				[1, 2, 3, 0, 0, 0],
				[0, 1, 2, 3, 0, 0],
				[0, 0, 1, 2, 3, 0],
				[5, 0, 0, 1, 2, 3],
				[0, 0, 0, 0, 1, 2]
			]
		end

	end
end
