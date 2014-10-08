require 'matrix'
require 'contracts'
require 'test/unit'
require_relative 'sparse_hash'
require_relative '../contracts/contract_extensions'
require_relative '../contracts/invariant'

class SparseMatrix < Matrix
	include Enumerable
	include Contracts
	include ContractExtensions
	include Test::Unit::Assertions
	extend Invariant

	attr_reader :row_count

	Contract Or[RespondTo[:to_i], EnumerableOf[RespondTo[:each_with_index]]], Maybe[RespondTo[:to_i]], Maybe[Func[Any => Any]] => SparseMatrix
	def initialize(rows, column_count = nil)
		assert(block_given?) if rows.respond_to? :to_i

		if rows.respond_to?(:to_i)
			rows = rows.to_i
			column_count = column_count.nil? ? rows : column_count.to_i
			create(rows, column_count) { |i,j| yield(i,j) }
		else
			column_count = column_count.nil? ? rows[0].size : column_count.to_i
			create(rows.size, column_count) { |i,j| rows[i][j] }
		end

		self
	end

	Contract RespondTo[:to_i] => Any
	def get(i, j)
		i = i.to_i
		j = j.to_i
		@rows[i][j] if @rows[i]
	end

	Contract RespondTo[:to_i], RespondTo[:to_i], Any => Any
	def set(i, j, v)
		i = i.to_i
		j = j.to_i
		return nil if i >= row_count || j >= column_count

		row = @rows[i]
		row[j] = v
		@rows[i] = row
	end

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

	# algebra
	
	def +(other)
		case other
		when Matrix
			merge(other) { |_, _, v, v2| v + v2 }
		else
			super(other)
		end
	end

	def -(other)
		case other
		when Matrix
			merge(other) { |_, _, v, v2| v - v2 }
		else
			super(other)
		end
	end

	def *(other)
		case other
		when Numeric
			self.class.build(row_count, column_count) { |i,j| self[i,j] * other }
		else
			super(other)
		end
	end

	# class methods

	Contract RespondTo[:to_i], Maybe[RespondTo[:to_i]], Maybe[Func[Any => Any]] => Or[Enumerable, SparseMatrix]
	def self.build(rows, cols = rows.to_i)
		return to_enum :build, rows, cols unless block_given?
		rows = rows.to_i
		new(rows, cols) { |i,j| yield(i,j) }
	end

	Contract EnumerableOf[Or[RespondTo[:each_with_index], RespondTo[:to_ary]]], Any => SparseMatrix
	def self.rows(rows, copy = true)
		rows = convert_to_multi_enum(rows, copy)
		new(rows, (rows[0] || []).size)
	end

	invariant(*(instance_methods(false) | Matrix.instance_methods(false))) do
		assert(@row_count >= 0)
		assert(@column_count >= 0)
	end

	alias_method :[]=, :set
	alias_method :[], :get

	private

	def dimensions_match(other)
		row_count == other.row_count && column_count == other.column_count
	end

	def create(row_count, column_count)
		@rows = row_count.times.inject(SparseHash.new(row_count) { SparseHash.new(column_count, 0) }) do |h, i|
			row = column_count.times.inject(h[i]) do |h1,j|
				h1[j] = yield(i,j)
				h1
			end
			h[i] = row if row.length > 0
			h
		end
		@column_count = column_count
		@row_count = row_count
	end

	def merge(other)
		raise ArgumentError, "Matrix must be of same dimensions" unless dimensions_match(other)
		self.class.build(row_count, column_count) { |i,j| yield(i, j, self[i,j], other[i,j]) }
	end

	module ConversionHelper
		def convert_to_multi_enum(obj, copy = true)
			obj.each_with_index.inject(copy ? obj.dup : obj) do |obj, (row, i)|
				if row.respond_to? :each_with_index
					obj[i] = row.dup if copy
				else
					obj[i] = convert_to_array(row, copy)
				end
				obj
			end
		end
	end
	extend ConversionHelper
end