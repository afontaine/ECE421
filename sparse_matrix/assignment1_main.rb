# Group 6i
# Andrew Fontaine
# Jacob Viau

require_relative 'sparse_matrix'

# Create is the same. TridiagonalMatrix will throw an exception if the matrix is not tridiagonal
sparse = MatrixFactory.create(
							  SparseMatrix,
							  [[1, 0, 0, 0, 5], [0, 2, 0, 4, 0], [0, 0, 3, 0, 0], [0, 2, 0, 4, 0], [0, 0, 0, 0, 5]]
							 )

# How to build different matricies
sparse = MatrixFactory.build(SparseMatrix, 30) do |i, j|
	next i * j + 1 if (i - 1.. i + 1) === j
	0
end

matr = MatrixFactory.build(Matrix, 30) do |i, j|
	next i * j + 1 if (i - 1.. i + 1) === j
	0
end

tridiag = MatrixFactory.build(TridiagonalMatrix, 30) do |i, j|
	i * j + 1
end

# Benchmarks
require 'test/unit'
require_relative './tests/sparse_benchmark_test'
require_relative './tests/tridiagonal_matrix_benchmark'

# Math
tridiag + sparse

sparse - tridiag

sparse**2

sparse * 2

tridiag * sparse

sparse / 2

tridiag.det

tridiag.inverse

# etc


# Properties
tridiag.diagonal?

sparse.square?

tridiag.real?

sparse.orthoganal?

# etc.

# Enumerate

sparse.each(:nonzero) { |x| x }

tridiag.each(:tridiagonal) { |x| x }

sparse.each_with_index(:nonzero) { |x, i, j|  x + i + j }

sparse.any? { |x| x != 0 }


