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

	delegate [:+, :*, :**, :/, :-] => :to_m

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

  def initialize(*args)
    if args.length == 3
      @upper_diagonal = args[0]
      @middle_diagonal = args[1]
      @lower_diagonal = args[2]
    else

    end
    self
  end

  def ==(other)
    return false unless other.respond_to?(:zip)
    zip(other).each.reduce(true) { |result, x| result && (x[1] == x[0]) }
  end

  def /(other)
    return self * other.inverse if other.respond_to?(:inverse)
    new_upper = @upper_diagonal.map { |x| x / other }
    new_middle = @middle_diagonal.map { |x| x / other }
    new_lower = @lower_diagonal.map { |x| x / other }
    TridiagonalMatrix.send(:new, new_upper, new_middle, new_lower)
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
		new_upper = @upper_diagonal.map(&block)
		new_middle = @middle_diagonal.map(&block)
		new_lower = @lower_diagonal.map(&block)
		TridiagonalMatrix.send(:new, new_upper, new_middle, new_lower)
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
		return to_enum :each unless block_given?
		each_with_index { |x| yield x }
		self
	end

	def each_with_index(which = :all)
		return to_enum :each_with_index unless block_given?
		row_count.times do |i|
			column_count.times do |j|
				yield self[i, j], i, j
			end
		end
		self
	end

	def coerce(other)
		[other, to_m]
	end

	def rows
		to_m.rows
	end

	def inverse
	end

	def square?
		true
	end

	def toeplitz?
		@upper_diagonal.reduce(true) { |a, e| a && e == @upper_diagonal[0] }
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
			.reduce([@upper_diagonal[0] / @middle_diagonal[0]]) do |c, x|
			c << x[0] / (x[1] - x[2] * c.last)
		end
	end

	def d_prime(vec, c)
		vec[1..-1].zip(@middle_diagonal[1..-1], @lower_diagonal, c).reduce([vec[0] / @middle_diagonal[0]]) do |d, x|
			d << (x[0] - x[2] * d.last) /
				(x[1] - x[2] * x[3])
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
end
