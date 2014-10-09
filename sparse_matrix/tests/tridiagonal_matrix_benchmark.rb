require 'benchmark'
require_relative '../data/tridiagonal_matrix'

mat = TridiagonalMatrix.build(500) { |x, y| x * y + 1 }
mat2 = mat.to_m

Benchmark.bm do |x|
	puts "Multiply by scalar"
	x.report { mat * 6 }
	x.report { mat2 * 6 }
	puts "Multiply by matrix"
	x.report { mat * mat2 }
	x.report { mat2 * mat2 }
	puts "Determinant"
	x.report { mat.determinant }
	x.report { mat2.determinant }
	puts "Divide by scalar"
	x.report { mat / 6 }
	x.report { mat2 / 6 }
	puts "Divide by matrix"
	x.report { mat / mat2 }
	x.report { mat2 / mat2 }
	puts "Inverse"
	x.report { mat.inverse }
	x.report { mat2.inverse }
	puts "to_m"
	x.report { mat.to_m }
	puts "Transpose"
	x.report { mat.transpose }
	x.report { mat2.transpose }
end
