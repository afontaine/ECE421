require_relative 'sparse_matrix'

sparse = MatrixFactory.build(SparseMatrix, 30) do |i, j|
	next i * j + 1 if (i - 1.. i + 1) === j
	0
end

puts sparse
puts sparse.det
puts sparse.inv
puts sparse.diagonal?
puts sparse * sparse == sparse**2

tridiag = MatrixFactory.create(sparse.rows, false)

puts tridiag == sparse
