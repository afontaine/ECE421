require 'test/unit'
require 'matrix'
require_relative '../tridiagonal_matrix'

class TridiagonalMatrixFactoryTest < Test::Unit::TestCase

	def test_create

		matrix_good = nil

		matrix_good = TridiagonalMatrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		assert_not_nil(matrix_good)
		assert_true(matrix_good.square?)

		puts matrix_good.to_s


		params_bad_upper = {}
		params_bad_upper[:upper] = params_good[:middle]
		params_bad_upper[:middle] = params_good[:middle]
		params_bad_upper[:lower] = params_good[:lower]

		assert_raise(Matrix::ErrDimensionMismatch) {factory.create(params_bad_upper)}

		params_bad_lower = {}
		params_bad_lower[:upper] = params_good[:upper]
		params_bad_lower[:middle] = params_good[:middle]
		params_bad_lower[:lower] = params_good[:middle]

		assert_raise(Matrix::ErrDimensionMismatch) {factory.create(params_bad_upper)}

	end
end
