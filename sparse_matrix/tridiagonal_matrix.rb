require 'matrix'

class TridiagonalMatrix < Matrix

	def initialize(upper, middle, lower)
		@upper_diagonal = upper
		@middle_diagonal = middle
		@lower_diagonal = lower
	end

	def self.rows(rows, copy=true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy)}
		size = (rows[0] || []).size
		upper = []
		middle = []
		lower = []
		rows.length.times do |x|
			rows[x].length.times do |y|
				case x
				when y - 1
					upper << rows[x][y]
				when y
					middle << rows[x][y]
				when y + 1
					lower << rows[x][y]
				else
					raise RuntimeError, "Matrix is not tridiagonal" unless rows[x][y] == 0
				end
			end
		end
		new upper, middle, lower
	end

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

	attr_accessor :upper_diagonal, :lower_diagonal, :middle_diagonal
end