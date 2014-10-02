require 'matrix'
require 'contracts'
require 'test/unit'
require_relative 'sparse_hash'
require_relative 'contracts\sparse_contracts'
require_relative 'contracts\invariant'

class SparseMatrix < Matrix
	include Enumerable
	include Contracts
	include Invariant
	include SparseContracts
	include Test::Unit::Assertions

	attr_reader :row_count

	Contract EnumerableOf[RespondTo[:each_with_index]], RespondTo[:to_i] => SparseMatrix
	def initialize(rows, column_count = rows[0].size)
		column_count = column_count.to_i
		rows_h = SparseHash.new(rows.size) { |h,k| SparseHash.new(column_count, 0) }

		rows.each_with_index do |row,i|
			row_h = rows_h[i]
			row.each_with_index do |val,j|
				row_h[j] = val
			end
			rows_h[i] = row_h if row_h.length > 0
		end

		@rows = rows_h
		@column_count = column_count
		@row_count = rows.size

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
		i = i.to_i
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

	Contract nil => SparseMatrix
	def transpose
		SparseMatrix.build(column_count, row_count) do |i,j|
			self[j,i]
		end
	end

	Contract Or[Symbol, Func[Any => Any], nil] => Or[Enumerator, SparseMatrix]
	def each(which = :all)
		return to_enum :each, which unless block_given?
		if which == :non_zero
			@rows.each(false) do |row|
				row.each(false) { |v| yield v }
			end
			self
		else
			super(which, &Proc.new)
		end
	end

	Contract Or[Symbol, Func[Any => Any], nil]  => Or[Enumerator, SparseMatrix]
	def each_with_index(which = :all)
		return to_enum :each_with_index, which unless block_given?
		if which == :non_zero
			@rows.each_with_index(false) do |row, i|
				row.each_with_index(false) { |value, j| yield value, i, j }
			end
			self
		else
			super(which, &Proc.new)
		end
	end

	Contract Args[Or[RespondTo[:to_i], RespondTo[:each]]] => SparseMatrix
	def minor(*args)
		SparseMatrix.rows(to_m.minor(*args).to_a)
	end

	Invariant.invariant(self, :get, :set, :[], :[]=, :row, :column, :+, :/, :*, :transpose, :each) do
		assert(@row_count >= 0)
		assert(@column_count >= 0)
		assert_equal(@rows[0].size, @column_count)
		assert_equal(@rows.size, @row_count)
	end
end