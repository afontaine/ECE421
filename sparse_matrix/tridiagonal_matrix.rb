require 'matrix'

class TridiagonalMatrix < Matrix

	include ExceptionForMatrix

	def initialize(upper, middle, lower)
		@upper_diagonal = upper
		@middle_diagonal = middle
		@lower_diagonal = lower
		self
	end

	def self.rows(rows, copy=true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy)}
		size = (rows[0] || []).size
		upper = []
		middle = []
		lower = []
		rows.each_with_index do |x, i|
			raise ErrDimensionMismatch, "row size differs (#{x.size} should be #{size})" unless x.size == size
			x.each_with_index do |y, j|
				case i
				when j - 1
					upper << y
				when j
					middle << y
				when j + 1
					lower << y
				else
					raise RuntimeError, "Matrix is not tridiagonal" unless y == 0
				end
			end
		end
		new upper, middle, lower
	end

	def self.[](*rows)
		rows(rows, false)
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

	alias :column_count :row_count

	def to_s
		string = ""
		@middle_diagonal.length.times { |x|
			line = ""

			@middle_diagonal.length.times { |y|
				case x
				when y - 1
					line += "#{@upper_diagonal[x]}\t"
				when y
					line += "#{@middle_diagonal[x]}\t"
				when y + 1
					line += "#{@lower_diagonal[y]}\t"
				else
					line += "0\t"
				end
			}
			string += "#{line}\n"
		}
		string
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

end