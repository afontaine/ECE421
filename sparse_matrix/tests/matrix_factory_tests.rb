require 'test/unit'

class MatrixFactoryTests < Test::Unit::TestCase

	def test_create
		rows = [
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]

		m = MatrixFactory.create(rows)

		assert_instance_of(Matrix, m)
		assert_not_instance_of(SparseMatrix, m)
		assert_not_nil(m)

		m = MatrixFactory.create(rows, SparseMatrix)

		assert_instance_of(SparseMatrix, m)
		assert_not_instace_of(Matrix, m)
		assert_kind_of(Matrix, m)

		m = MatrixFactory.create(rows, Matrix)

		assert_instance_of(Matrix, m)
		assert_not_instance_of(SparseMatrix, m)

		rows = [
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		m = MatrixFactory.create(rows, TridiagonalMatrix)
		assert_instance_of(TridiagonalMatrix, m)
		assert_not_instace_of(Matrix, m)
		assert_not_kind_of(Matrix, m)
	end
end
