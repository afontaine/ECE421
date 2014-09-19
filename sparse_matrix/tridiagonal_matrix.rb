require 'matrix'
require 'e2mmap.rb'
require 'mathn'

module ExceptionForTridiagionalMatrix
	extend ExceptionForMatrix
	extend Exception2MessageMapper
	def_exception('ErrNotTridiagonal', 'Not Tridiagonal Matrix')
end

class TridiagonalMatrix < Matrix

	include ExceptionForTridiagionalMatrix

	alias :column_count :row_count
	alias :det :determinant

	def initialize(upper, middle, lower)
		@upper_diagonal = upper
		@middle_diagonal = middle
		@lower_diagonal = lower
		self
	end

	def self.rows(rows, copy = true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy) }
		size = (rows[0] || []).size
		square_size = rows.size
		upper = []
		middle = []
		lower = []
		rows.each_with_index do |x, i|
			fail ErrDimensionMismatch,
			     "row size differs (#{x.size} should be #{size})" unless x.size == size
			fail ErrDimensionMismatch,
			     "matrix not square (#{x.size} should be #{square_size})" unless x.size == square_size
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

	def self.identity(size)
		upper = Array.new(size) { 0 }
		middle = Array.new(size) { 1 }
		lower = Array.new(size) { 0 }
		new upper, middle, lower
	end

	def square?
		true
	end

	def row_count
		middle_diagonal.size
	end

	def to_s
		string = "#{self.class.name}["
		@middle_diagonal.length.times do |x|
			line = []

			@middle_diagonal.length.times do |y|
				line << get_value(x, y)
			end
			string += "#{line}"
		end
		string += ']'
		string
	end

	def each(which = :all)
		return to_enum :each, which unless block_given?

		case which

		when :all
			@middle_diagonal.each_with_index do |_x, i|
				@middle_diagonal.each_with_index do |_y, j|
					yield get_value(i, j)
				end
			end
		when :diagonal
			block = Proc.new
			@middle_diagonal.each(&block)
		when :tridiagonal
			@middle_diagonal.each_with_index do |_x, i|
				yield @lower_diagonal[i - 1] if i > 0
				yield @middle_diagonal[i]
				yield @upper_diagonal[i] if i < @lower_diagonal.size
			end
		when :off_diagonal
			@middle_diagonal.each_with_index do |_x, i|
				(0...i).each do
					yield 0
				end if i > 0
				yield @lower_diagonal[i - 1] if i > 0
				yield @upper_diagonal[i] if i < @upper_diagonal.size
				(i...@upper_diagonal.size).each do
					yield 0
				end if i < @upper_diagonal.size
			end
		end
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
		Vector[@upper_diagonal]
	end

	def middle_diagonal
		Vector[@middle_diagonal]
	end

	def lower_diagonal
		Vector[@lower_diagonal]
	end

		private

	attr_writer :upper_diagonal, :middle_diagonal, :lower_diagonal

	def continuant(n)
		return 1 if n == -1
		return @middle_diagonal[0] if n == 0
		@middle_diagonal[n] * continuant(n - 1) - @upper_diagonal[n - 1] *
			@lower_diagonal[n - 1] * continuant(n - 2)
	end

	def c_prime
		c = []
		@upper_diagonal.each_with_index do |x, i|
			if i == 0
				c << x / @middle_diagonal[i]
			else
				c << x / (@middle_diagonal[i] - @lower_diagonal[i] * c.last)
			end
		end
		c
	end

	def d_prime(vec, c)
		d = []
		vec.each_with_index do |x, i|
			if i == 0
				d << x / @middle_diagonal[i]
			else
				d << (x - @lower_diagonal[i - 1] * d.last) /
					(@middle_diagonal[i] - @lower_diagonal[i - 1] * c[i - 1])
			end
		end
	end

	def x_prime(c, d)
		x = []
		(d.size - 1).downto(0) do |i|
			if i == d.size - 1
				x << d[i]
			else
				x << d[i] - c[i] * x.last
			end
		end
	end
end
