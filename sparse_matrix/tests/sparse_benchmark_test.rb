require 'test/unit'
require 'benchmark'
require_relative '../sparse_matrix'


class SparseBenchmarkTest < Test::Unit::TestCase

	# Called before every test method runs. Can be used
	# to set up fixture information.
	def setup
		# Do nothing
	end

	# Called after every test method runs. Can be used to tear
	# down fixture information.

	def teardown
		# Do nothing
	end

	# Fake test
	def test_benchmarks
		rows, cols = 500, 500
		puts "#{rows} x #{cols}"
		sm, m = nil, nil

		Benchmark.bm do |x|

			puts 'build'
			x.report('Sparse') do
				sm = MatrixFactory.build(SparseMatrix, rows, cols) do |i,j|
					i == j ? 10 : 0
				end
			end
			x.report('Matrix') do
				m = MatrixFactory.build(Matrix, rows, cols) do |i,j|
					i == j ? 10 : 0
				end
			end
			puts ''

			puts 'identity'
			x.report('Sparse') do
				SparseMatrix.I(rows)
			end
			x.report('Matrix') do
				Matrix.I(rows)
				end
			puts ''

			puts 'multiplication'
			x.report('Sparse') { sm * 10 }
			x.report('Matrix') { m * 10 }
			puts ''

			puts 'addition'
			x.report('Sparse') { sm + sm }
			x.report('Matrix') { m + m }
			puts ''

			puts 'matrix multiplication'
			x.report('Sparse') { sm * sm }
			x.report('Matrix') { m * m }
			puts ''

		end
	end
end