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
puts sparse.lup.solve(Vector.elements(Array.new(30) { 1 }))

tridiag = MatrixFactory.create(TridiagonalMatrix, sparse.to_a)

puts tridiag == sparse
puts sparse + tridiag
puts tridiag.equal?(sparse)
puts tridiag.solve(Vector.elements(Array.new(30) { 1 }))

sparse = MatrixFactory.create(
							  SparseMatrix,
							  [[1, 0, 0, 0, 5], [0, 2, 0, 4, 0], [0, 0, 3, 0, 0], [0, 2, 0, 4, 0], [0, 0, 0, 0, 5]]
							 )

puts sparse.det