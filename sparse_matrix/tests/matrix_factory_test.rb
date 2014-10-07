require 'test/unit'
require_relative '../sparse_matrix'

class MatrixFactoryTest < Test::Unit::TestCase

	def test_create
		rows = [
			[1,0,0,0,0],
			[0,0,0,0,0],
			[-9,0,0,0,0],
			[0,0,100,0,0],
			[0,0,0,0,99]
		]

		m = MatrixFactory.create(Matrix, rows)

		assert_instance_of(Matrix, m)
		assert_false(m.instance_of? SparseMatrix)
		assert_not_nil(m)

		m = MatrixFactory.create(SparseMatrix, rows)

		assert_instance_of(SparseMatrix, m)
    assert_false(m.instance_of? Matrix)
		assert_kind_of(Matrix, m)

		rows = [
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		m = MatrixFactory.create(TridiagonalMatrix, rows)
		assert_instance_of(TridiagonalMatrix, m)
    assert_false(m.instance_of? Matrix)
		assert_not_kind_of(Matrix, m)

    assert_raise(Contract::ContractError) do
      MatrixFactory.create(Array, [[1, 2, 3],[2,3,4]])
    end

    assert_raise(Contract::ContractError) do
      MatrixFactory.create(SparseMatrix, [1, 2, 3, 2,3,4])
    end
	end

	def test_build
		m = MatrixFactory.build(Matrix, 4, 4) { |row, col| row * col}
		assert_instance_of(Matrix, m)
    assert_false(m.instance_of? SparseMatrix)
		assert_not_nil(m)

		m = MatrixFactory.build(SparseMatrix, 4) { |row, col| row * col}
		assert_instance_of(SparseMatrix, m)
    assert_false(m.instance_of? Matrix)
		assert_kind_of(Matrix, m)

		m = MatrixFactory.build(TridiagonalMatrix, 4, 4) { |row, col| row * col}
		assert_instance_of(TridiagonalMatrix, m)
    assert_false(m.instance_of? Matrix)
		assert_not_kind_of(Matrix, m)
	end
end
