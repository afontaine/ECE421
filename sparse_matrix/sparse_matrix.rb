require 'matrix'

class SparseMatrix < Matrix

	include ExceptionForMatrix

	def initialize(values, columns, row_ptrs, col_count)
		@values = values
		@columns = columns
		@row_ptrs = row_ptrs
		@col_count = col_count
	end

	def self.rows(rows, copy=true)
		rows = convert_to_array(rows)
		rows.map! { |row| convert_to_array(row, copy) }
		size = (rows[0] || []).size
		values = []
		columns = []
		row_ptrs = []

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
			row_ptrs << first
		end
		row_ptrs << values.size
		new values, columns, row_ptrs, size
	end

	def self.each(which = :all)
		return to_enum :each, which unless block_given?

		case which
		when :all
			block = Proc.new
			to_a.each do |row|
				row.each(&block)
			end
		else
			raise ArgumentError, "expected #{which.inspect} to be one of :all, :diagonal, :off_diagonal, :lower, :strict_lower, :strict_upper, :upper, or :non_zeros "
		end
	end

	def square?
		row_count == col_count
	end

	def values
		Vector.elements(@values)
	end

	def columns
		Vector.elements(@columns)
	end

	def row_ptrs
		Vector.elements(@row_ptrs)
	end

	def row_count
		@row_ptrs.size - 1
	end

	def inspect
		"#{self.class}[Values#{@values.inspect}Columns#{@columns.inspect}RowIndex#{@row_ptrs.inspect}]"
	end

	def to_s
		"Sparse" + to_m.to_s
	end

	def to_m
		Matrix.rows(to_a)
	end

	def to_a
		a = Array.new(row_count) { Array.new(col_count) { 0 }}
		
		@row_ptrs[0..@row_ptrs.size - 2].each_with_index do |row_ptr_min, row|
			next if row_ptr_min < 0
			row_ptr_max = get_next_row_ptr(row)

			(row_ptr_min..row_ptr_max - 1).step(1) do |i|
				a[row][@columns[i]] = @values[i]
			end 
		end
		a
	end

	attr_reader :col_count

	private
	attr_writer :values, :columns, :row_ptrs, :col_count

	def get_value(row, col)
		row_ptr_min = @row_ptrs[row]
		return 0 if row_ptr_min < 0

		row_ptr_max = get_next_row_ptr(row)

		(row_ptr_min...row_ptr_max).each do |i|
			return @values[i] if @columns[i] == col
		end

		return 0
	end

	def get_next_row_ptr(index)
		i = 1
		next_ptr = @row_ptrs[index + i]
		unless next_ptr >= 0
			i += 1
			next_ptr = @row_ptrs[index + i]
		end
		next_ptr
	end

end