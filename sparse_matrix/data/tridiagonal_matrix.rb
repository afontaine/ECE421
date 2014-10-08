require 'matrix'
require 'forwardable'
require 'e2mmap.rb'

module ExceptionForTridiagionalMatrix
	extend ExceptionForMatrix
	extend Exception2MessageMapper
	def_exception(:ErrNotTridiagonal, 'The matrix is not tridiagonal')
end

class TridiagonalMatrix < Matrix

	include ExceptionForTridiagionalMatrix
	extend Forwardable
	extend Enumerable

	delegate [:+, :**, :-, :hermitian?, :normal?, :permutation?] => :to_m


	public

	def self.rows(rows, copy = true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy) }
		size = (rows[0] || []).size
		upper = []
		middle = []
		lower = []
		rows.each_with_index do |x, i|
			fail ErrDimensionMismatch,
			"row size differs (#{x.size} should be #{size})" unless x.size == size
			fail ErrDimensionMismatch,
			"matrix not square (#{x.size} should be #{rows.size})" unless x.size == rows.size
			x.each_with_index do |y, j|
				case i
				when j - 1
						upper << y
					when j
						middle << y
					when j + 1
						lower << y
					else
						fail ErrNotTridiagonal, 'Matrix is not tridiagonal' unless y == 0
				end
			end
		end
		new upper, middle, lower
	end

	def self.build(row_count, col_count = row_count)
		return :to_enum unless block_given?
		upper = Array.new(row_count) { |x| yield x, x + 1 }
		middle = Array.new(row_count) { |x| yield x, x }
		lower = Array.new(row_count) { |x| yield x - 1, x }
		new upper, middle, lower
	end

	def self.identity(size)
		scalar(size, 1)
	end

	def self.scalar(n, value)
		upper = Array.new(n) { 0 }
		middle = Array.new(n) { value }
		lower = Array.new(n) { 0 }
		new upper, middle, lower
	end

	def initialize(upper, middle, lower)
		@upper_diagonal = upper
		@middle_diagonal = middle
		@lower_diagonal = lower
		self
	end

	def ==(other)
		return false unless other.respond_to?(:zip)
		zip(other).each.reduce(true) { |result, x| result && (x[1] == x[0]) }
	end


	def /(other)
		return self * other.inverse if other.respond_to?(:inverse)
		map { |x| x / other }
	end

	def *(other)
		return to_m * other if other.respond_to?(:each)
		map { |x| x * other }
	end

	def eql?(other)
		return false unless other.respond_to?(:upper_diagonal) &&
		other.respond_to?(:middle_diagonal) &&
		other.respond_to?(:lower_diagonal)
		(upper_diagonal.eql?(other.upper_diagonal) &&
		middle_diagonal.eql?(other.middle_diagonal) &&
		lower_diagonal.eql?(other.lower_diagonal))
	end

	def hash
		@upper_diagonal.hash ^ @middle_diagonal.hash ^ @lower_diagonal.hash
	end

	def map
		return to_enum :map unless block_given?
		block = Proc.new
		TridiagonalMatrix.send(:new, @upper_diagonal.map(&block), @middle_diagonal.map(&block), @lower_diagonal.map(&block))
	end

	def row(i)
		return self unless i < row_count
		row = Array.new(row_count) { |j| self[i, j] }
		row.each(&Proc.new) if block_given?
		Vector.elements(row, false)
	end

	def column(j)
		return self unless j < column_count
		col = Array.new(column_count) { |i| self[i, j] }
		col.each(&Proc.new) if block_given?
		Vector.elements(col, false)
	end

	def each(which = :all)
		return to_enum :each, which unless block_given?
		each_with_index(which) { |x| yield x }
		self
	end

	def each_with_index(which = :all)
		return to_enum :each_with_index, which unless block_given?
		if which == :tridiagonal
			row_count.times do |i|
				yield @lower_diagonal[i - 1], i, i - 1 if i > 0
				yield @middle_diagonal[i], i, i
				yield @upper_diagonal[i], i, i + 1 if i + 1 < row_count
			end
			self
		elsif which == :diagonal
			@middle_diagonal.each_with_index(&Proc.new)
		else
			to_m.each_with_index(which, &Proc.new)
		end
	end

	def coerce(other)
		[other, to_a]
	end

	def rows
		to_m.rows
	end

	def inverse
		thet = theta
		ph = phi
		Matrix.build(row_count) do |i, j|
			next thet[i] * ph[i + 1].quo(thet.last) if i == j
			next ((-1)**(i + j)) * @upper_diagonal[i...j].reduce(:*) * thet[i] * ph[j + 1].quo(thet.last) if i < j
			next ((-1)**(i + j)) * @lower_diagonal[j..i].reduce(:*) * thet[j] * ph[i + 1].quo(thet.last) if i > j
		end
	end

	def square?
		true
	end

	def diagonal?
		@upper_diagonal.all? { |x| x == 0} && @lower_diagonal.all? { |x| x == 0 }
	end

	def toeplitz?
		@upper_diagonal.reduce(true) { |a, e| a && e == @upper_diagonal[0] }
	end

	def upper_triangular?
		false
	end

	def orthogonal?
		transpose == inverse
	end

	def symmetric?
		self == transpose
	end

	def row_count
		@middle_diagonal.size
	end

	def to_s
		"#{self.class.name}#{to_a}"
	end

	def to_a
		Array.new(row_count) { |i|	row(i).to_a }
	end

	def to_m
		Matrix.rows(to_a, false)
	end

	def transpose!
		@upper_diagonal, @lower_diagonal = @lower_diagonal, @upper_diagonal
		self
	end

	def transpose
		TridiagonalMatrix.send(:new, @lower_diagonal, @middle_diagonal, @upper_diagonal)
	end

	def solve(vec)
		c = c_prime
		Vector.elements(x_prime(c, d_prime(vec, c)).reverse)
	end

	def trace
		@middle_diagonal.reduce(:+)
	end

	def get_value(row, col)
		case row
		when col - 1
				return @upper_diagonal[row]
			when col
				return @middle_diagonal[row]
			when col + 1
				return @lower_diagonal[col]
			else
				return 0
		end
	end

	def determinant
		continuant(@middle_diagonal.size - 1)
	end

	def upper_diagonal
		Vector.elements(@upper_diagonal)
	end

	def middle_diagonal
		Vector.elements(@middle_diagonal)
	end

	def lower_diagonal
		Vector.elements(@lower_diagonal)
	end


	alias_method :column_count, :row_count
	alias_method :det, :determinant
	alias_method :inspect, :to_s
	alias_method :[], :get_value
	alias_method :collect, :map
	alias_method :lower_triangular?, :upper_triangular?
	alias_method :tr, :trace
	alias_method :t, :transpose

	private

	attr_writer :upper_diagonal, :middle_diagonal, :lower_diagonal

	def continuant(n)
		return 1 if n == -1
		return @middle_diagonal[0] if n == 0
		@middle_diagonal[n] * continuant(n - 1) - @upper_diagonal[n - 1] *
			@lower_diagonal[n - 1] * continuant(n - 2)
	end

	def c_prime
		@upper_diagonal[1..-1].zip(@middle_diagonal[1..-1], @lower_diagonal)\
			.reduce([@upper_diagonal[0].quo(@middle_diagonal[0])]) do |c, x|
			c << x[0].quo(x[1] - x[2] * c.last)
		end
	end

	def d_prime(vec, c)
		vec[1..-1].zip(@middle_diagonal[1..-1], @lower_diagonal, c).reduce([vec[0].quo(@middle_diagonal[0])]) do |d, x|
			d << (x[0] - x[2] * d.last).quo(x[1] - x[2] * x[3])
		end
	end

	def x_prime(c, d)
		d[0..-2].reverse.zip(c.reverse).reduce([d.last]) do |x, d_c|
			x << d_c[0] - d_c[1] * x.last
		end
	end

	def theta
		@middle_diagonal[1..-1].zip(@upper_diagonal, @lower_diagonal)\
			.reduce([1, @middle_diagonal[0]]) do |thet, x|
			thet << x[0] * thet[-1] - x[1] * x[2] * thet[-2]
		end
	end

	def phi
		@middle_diagonal[0..-2].reverse.zip(@upper_diagonal.reverse, @lower_diagonal.reverse)\
			.reduce([1, @middle_diagonal.last]) do |ph, x|
			ph << x[0] * ph.last - x[1] * x[2] * ph[-2]
		end.reverse
	end
end
