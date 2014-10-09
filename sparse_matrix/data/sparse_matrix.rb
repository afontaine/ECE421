require 'matrix'
require 'contracts'
require 'test/unit'
require_relative 'sparse_hash'
require_relative '../contracts/matrix_contract'

class SparseMatrix < Matrix
	include Test::Unit::Assertions
	include Enumerable

	attr_reader :row_count

	def initialize(rows, column_count = nil, &block)
		assert(block_given?) if rows.respond_to? :to_i
		column_count ||= rows.respond_to?(:to_i) ? rows : rows[0].size

		if rows.respond_to?(:to_i)
			create(rows, column_count, &block)
		elsif rows.is_a?(SparseHash) && rows[0].is_a?(SparseHash)
			@rows = rows
			@row_count = rows.size
			@column_count = column_count
		else
			create(rows.size, column_count) { |i,j| rows[i][j] }
		end

		self
	end

	def get(i, j)
		@rows[i][j] if @rows[i]
	end

	def set(i, j, v)
		return nil unless i.between?(0, row_count - 1) && j.between?(0, column_count - 1)
		self.class.set_in_multi_hash(@rows, i, j, v)
	end

	def row(i)
		return nil unless i.abs.between?(0, row_count-1)
		Vector.elements(Array.new(column_count) { |j| self[i,j] })
	end

	def to_m
		Matrix.rows(self.to_a)
	end

	def to_a
		Array.new(row_count) { |i| Array.new(column_count) { |j| self[i,j] } }
	end

	def transpose
		SparseMatrix.build(column_count, row_count) do |i,j|
			self[j,i]
		end
	end

	def each(which = :all, &block)
		return to_enum :each, which unless block_given?
		if which == :non_zero
			@rows.each(false) do |row|
				row.each(false, &block)
			end
			self
		else
			super(which, &block)
		end
	end

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

	def minor(*args)
		SparseMatrix.rows(to_m.minor(*args).to_a)
	end

	# algebra
	
	def +(other)
		case other
			when Matrix
				merge(other) { |v, v2| v + v2 }
			else
				super(other)
		end
	end

	def -(other)
		case other
			when Matrix
				merge(other) { |v, v2| v - v2 }
			else
				super(other)
		end
	end

	def *(other)
		case other
			when Numeric
				new_matrix duplicate { |v| v * other }
			else
				super(other)
		end
	end

	def /(other)
		case other
			when Numeric
				new_matrix duplicate { |v| v / other }
			else
				super(other)
		end
	end

	# class methods

	def self.diagonal(*values)
		h = default_sparse_hash(values.size, values.size)
		values.each_with_index do |v, i|
			set_in_multi_hash(h, i, i, v)
		end
		new h
	end

	def self.build(rows, cols = rows.to_i, &block)
		return to_enum :build, rows, cols unless block_given?
		new(rows, cols, &block)
	end

	def self.rows(rows, copy = true)
		rows = convert_to_multi_enum(rows, copy)
		new(rows, (rows[0] || []).size)
	end

	alias_method :[]=, :set
	alias_method :[], :get

	private

	def dimensions_match(other)
		row_count == other.row_count && column_count == other.column_count
	end

	def create(row_count, column_count)
		h = self.class.default_sparse_hash(row_count, column_count)
		row_count.times do |i|
			row = h[i]
			column_count.times do |j|
				row[j] = yield(i,j)
			end
			h[i] = row
		end
		@rows = h
		@column_count = column_count
		@row_count = row_count
	end

	def merge(other)
		raise ArgumentError, 'Matrix must be of same dimensions' unless dimensions_match(other)
		if other.is_a? SparseMatrix
			sparse_merge(other, &Proc.new)
		else
			self.class.build(row_count, column_count) { |i,j| yield(self[i,j], other[i,j]) }
		end
	end

	def sparse_merge(other)
		h = duplicate { |v| v }
		other.each_with_index(:non_zero) do |v, i, j|
			self.class.set_in_multi_hash(h, i, j, yield(h[i][j], v))
		end
		new_matrix h
	end

	def duplicate
		h = self.class.default_sparse_hash(row_count, column_count)
		self.each_with_index(:non_zero) do |v, i, j|
			self.class.set_in_multi_hash(h, i, j, yield(v))
		end
		h
	end

	def self.default_sparse_hash(rows, cols)
		SparseHash.new(rows) { SparseHash.new(cols, 0) }
	end

	def self.set_in_multi_hash(h, i, j, v)
		row = h[i]
		row[j] = v
		h[i] = row
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