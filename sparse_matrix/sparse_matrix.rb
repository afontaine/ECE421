require 'matrix'
require 'contracts'
require_relative 'sparse_hash'
require_relative 'contracts\sparse_contracts'

class SparseMatrix < Matrix
	include Contracts
	include SparseContracts

	attr_reader :row_count

	Contract EnumerableOf[RespondTo[:each]], RespondTo[:to_i] => SparseMatrix
	def initialize(rows, column_count = rows[0].size)
		column_count = column_count.to_i
		create(rows.size, column_count) do |i,j|
			rows[i][j]
		end			
		self
	end

	Contract RespondTo[:to_i] => Any
	def get(i, j)
		i = i.to_i
		j = j.to_i
		@rows[i][j] if @rows[i]
	end

	alias_method :[], :get

	Contract RespondTo[:to_i], RespondTo[:to_i], Any => Any
	def set(i, j, v)
		i = i.to_i
		j = j.to_i
		@rows[i][j] = v if @rows[i] && j < column_count
	end

	alias_method :[]=, :set

	Contract RespondTo[:to_i] => Maybe[Vector]
	def row(i)
		return nil unless i.abs.between?(0, row_count-1)
		Vector.elements(Array.new(column_count) { |j| self[i,j] })
	end

	Contract nil => Matrix
	def to_m
		Matrix.rows(self.to_a)
	end

	Contract nil => Array
	def to_a
		Array.new(row_count) { |i| Array.new(column_count) { |j| self[i,j] } }
	end

	Contract Maybe[Func[Any => Any]] => RespondTo[:each]
	def each
		return to_enum :each unless block_given?
		row_count.times do |i|
			column_count.times do |j|
				yield self[i][j]
			end
		end
		self
	end

	def transpose
		SparseMatrix.build(column_count, row_count) do |i,j|
			self[j,i]
		end
	end

	private

	def create(row_count, column_count)
		rows_h = SparseHash.new(row_count) { SparseHash.new(column_count, 0) }
		row_count.times do |i|
			row_h = rows_h[i]
			column_count.times do |j|
				val = yield i,j
				row_h[j] = val if val != 0
			end
			rows_h[i] = row_h if row_h.size > 0
		end

		@rows = rows_h
		@column_count = column_count
		@row_count = row_count
	end
end