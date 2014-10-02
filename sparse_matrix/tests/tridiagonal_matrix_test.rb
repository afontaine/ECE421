require 'test/unit'
require 'matrix'
require_relative '../tridiagonal_matrix'

class TridiagonalMatrixFactoryTest < Test::Unit::TestCase
	def setup
		assert_nothing_raised do
				@m = TridiagonalMatrix[
					[2, 3, 0, 0, 0, 0],
					[1, 2, 3, 0, 0, 0],
					[0, 1, 2, 3, 0, 0],
					[0, 0, 1, 2, 3, 0],
					[0, 0, 0, 1, 2, 3],
					[0, 0, 0, 0, 1, 2]
			]
		end
		@rm = Matrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]

		@test_m = Matrix.build(6) { |x| x }

		invariants
	end

	def teardown
		invariants
	end

	def invariants
		assert_compare(0, "<", @m.row_count)
		assert_equal(@m.row_count, @m.colunn_count)
		assert_true(@m.square?)
		assert_true(@m.each_with_index.reduce(true) do |a, x|
			return o && x[0] == 0 unless (x[2] - 1..x[2] + 1) === x[1]
			o
		end)
	end

	def test_create
		assert_not_nil(@m)
		assert_instance_of(TridiagonalMatrix, @m)
		assert_kind_of(Matrix, @m)

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

	def test_sqaure
		assert_true(@m.square?)
		assert_equal(@m.row_count, @m.column_count)
	end

	def test_aliases
		assert_alias_method(@m, :column_count, :row_count)
		assert_alias_method(@m, :det, :determinant)
		assert_alias_method(@m, :inspect, :to_s)
		assert_alias_method(@m, :[], :get_value)
		assert_alias_method(@m, :collect, :map)
	end

	def test_empty
		assert_false(@m.empty?)
	end

	def test_equivalence
		assert_equal(@m, @rm)
		assert_equal(@rm, @m)
		assert_equal(TridiagonalMatrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		], @m)
		assert_equal(@rm, @m.to_m)
		assert_not_same(@rm, @m)
		assert_not_same(TridiagonalMatrix[
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		], @m)
	end

	def test_determinant
		assert_equal(@rm.det, @m.det)
	end

	def test_get_value
		assert_equal(2, @m[3, 3])
		assert_equal(3, @m[2, 3])
		assert_equal(1, @m[4, 3])
		assert_equal(0, @m[5, 3])
	end

	def test_accessors
		assert_equal(Vector[3, 3, 3, 3, 3], @m.upper_diagonal)
		assert_equal(Vector[2, 2, 2, 2, 2, 2], @m.middle_diagonal)
		assert_equal(Vector[1, 1, 1, 1, 1], @m.lower_diagonal)
		assert_equal(6, @m.row_count)
	end

	def test_solve
		s = Vector[1, 1, 1, 1, 1, 1]
		assert_equal(@rm.lup.solve(s), @m.solve(s))
	end

	def test_to_a
		assert_equal([
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		], @m.to_a)
	end

	def test_transpose
		a = [
			[2, 3, 0, 0, 0, 0],
			[1, 2, 3, 0, 0, 0],
			[0, 1, 2, 3, 0, 0],
			[0, 0, 1, 2, 3, 0],
			[0, 0, 0, 1, 2, 3],
			[0, 0, 0, 0, 1, 2]
		]
		assert_equal(@m.transpose, @rm.transpose)
		assert_equal(@m.transpose, a.transpose)
	end

	def test_collect
		assert_equal(TridiagonalMatrix[
				[4, 6, 0, 0, 0, 0],
				[2, 4, 6, 0, 0, 0],
				[0, 2, 4, 6, 0, 0],
				[0, 0, 2, 4, 6, 0],
				[0, 0, 0, 2, 4, 6],
				[0, 0, 0, 0, 2, 4]
			], @m.map { |x| x*2 })
	end

	def test_singluar
		assert_false(@m.singular?)
		assert_true(@m.regular?)
	end

	def test_mul
		assert_equal(TridiagonalMatrix[
				[2, 3, 0, 0, 0, 0],
				[1, 2, 3, 0, 0, 0],
				[0, 1, 2, 3, 0, 0],
				[0, 0, 1, 2, 3, 0],
				[0, 0, 0, 1, 2, 3],
				[0, 0, 0, 0, 1, 2]], @m * Matrix.I(6))
		assert_equal(TridiagonalMatrix[
				[4, 6, 0, 0, 0, 0],
				[2, 4, 6, 0, 0, 0],
				[0, 2, 4, 6, 0, 0],
				[0, 0, 2, 4, 6, 0],
				[0, 0, 0, 2, 4, 6],
				[0, 0, 0, 0, 2, 4]], @m * 2)
		assert_equal(Matrix[
			[13, 8, 3, 0, 0, 0],
			[8, 14, 8, 3, 0, 0],
			[3, 8, 14, 8, 3, 0],
			[0, 3, 8, 14, 8, 3],
			[0, 0, 3, 8, 14, 8],
			[0, 0, 0, 3, 8, 5]], @m * @m.transpose)
		assert_equal(@rm * @test_m, @m * @test_m)
		assert_equal(@test_m * @rm, @test_m * @m)
		assert_raise(TypeError) { @m * "This is wrong" }
	end

	def test_exp
		assert_equal(@m * @m, @m ** 2)
		assert_equal(@rm.inverse, @m * -1)
		assert_raise(TridiagonalMatrix::ErrOperationNotDefined) { @m ** "Still wrong"}
	end

	def test_div
		assert_equal(Matrix.I(6), @m / @m)
		assert_equal(TridiagonalMatrix[
				[Rational(2,2), Rational(3,2), 0, 0, 0, 0],
				[Rational(1,2), Rational(2,2), Rational(3,2), 0, 0, 0],
				[0, Rational(1,2), Rational(2,2), Rational(3,2), 0, 0],
				[0, 0, Rational(1,2), Rational(2,2), Rational(3,2), 0],
				[0, 0, 0, Rational(1,2), Rational(2,2), Rational(3,2)],
				[0, 0, 0, 0, Rational(1,2), Rational(2,2)]], @m / 2)
		assert_equal(@rm / @test_m, @m / @test_m)
		assert_equal(@test_m / @rm, @test_m / @m)
		assert_raise(TridiagonalMatrix::ErrOperationNotDefined) { @m / "Yep, wrong"}
	end

	def test_trace
		assert_equal(12, @m.trace)
	end
end
