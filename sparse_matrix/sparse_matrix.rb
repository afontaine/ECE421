require 'matrix'

class SparseMatrix < Matrix

	include ExceptionForMatrix

	def initialize(values, columns, row_index, col_count)
		@values = values
		@columns = columns
		@row_index = row_index
		@col_count = col_count
	end

	def self.rows(rows, copy=true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy) }
		size = (rows[0] || []).size
		values = []
		columns = []
		row_index = []

		rows.each_with_index do |x,i|
			raise ErrDimensionMismatch, "row size differs (#{x.size} should be #{size})" unless x.size == size
			first = -1
			x.each_with_index do |y,j|
				if y != 0
					values << y
					columns << j
					first = values.size - 1 if first == -1
				end
			end
			row_index << first
		end
		row_index << values.size
		new values, columns, row_index, size
	end

	def inspect
		"#{self.class}[Values#{@values.inspect}Columns#{@columns.inspect}RowIndex#{@row_index.inspect}]"
	end

	def to_s
		"Sparse" + to_m.to_s
	end

	def to_m
		Matrix.build(row_count, col_count) { |row, col|
			get_value(row, col)
		}
	end

	def values
		Vector[@values]
	end

	def columns
		Vector[@columns]
	end

	def row_index
		Vector[@row_index]
	end

	def row_count
		@row_index.size - 1
	end

	attr_reader :col_count

	private
	attr_writer :values, :columns, :row_index, :col_count

	def get_value(row, col)
		row_ptr_min = @row_index[row]
		return 0 if row_ptr_min == -1

		i = 1
		row_ptr_max = @row_index[row + i]

		while row_ptr_max == -1
			i += 1
			row_ptr_max = @row_index[row + i]
		end

		(row_ptr_min...row_ptr_max).each do |i|
			return @values[i] if @columns[i] == col
		end

		return 0
	end

end