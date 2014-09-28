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

		SparseMatrix.create(rows.size, size) do |i,j| 
			raise ErrDimensionMismatch, "row size differs (#{x.size} should be #{size})" unless rows[i].size == size
			rows[i][j]
		end
	end

	def self.build(row_count, column_count = row_count)
		row_count = Matrix::CoercionHelper.coerce_to_int(row_count)
		column_count = Matrix::CoercionHelper.coerce_to_int(column_count)
		return to_enum :build, row_count, column_count unless block_given?
		self.create(row_count, column_count, &Proc.new)
	end

	def collect
		return to_enum(:collect) unless block_given?
		a = to_a
		SparseMatrix.create(row_count, col_count) do |i,j|
			yield a[i][j]
		end
	end

	alias :map :collect

	def transpose

	end

	def each
		return to_enum :each unless block_given?
		each_with_index do |val|
			yield val
		end
	end

	def each_with_index
		return to_enum :each_with_index unless block_given?
		to_a.each_with_index do |row, i|
			row.each_with_index do |val, j|
				yield val, i, j
			end
		end
	end

	def row(i)
		return self unless i < row_count
		Vector.elements(get_row(i))
	end

	def column(j)
		c = []
		@columns.each_with_index do |col, index|
			c <<  col == j ? @values[index] : 0
		end
		Vector.elements(c)
	end

	def row_vectors
		get_arrays { |arr| Vector.elements(arr) }
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
		@row_ptrs.size
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
		get_arrays
	end

	attr_reader :col_count

	private
	attr_writer :values, :columns, :row_ptrs, :col_count

	def get_value(row, col)
		return nil if row >= row_count || col >= col_count

		row_ptr_min = @row_ptrs[row]
		return 0 if row_ptr_min < 0

		row_ptr_max = get_next_row_ptr(row)

		cols = @columns.slice(row_ptr_min...row_ptr_max)
		val = cols.bsearch { |x| x == col }
		val != nil ? val : 0
	end

	def get_row(i, default = nil)
		row_ptr_min = @row_ptrs.fetch(i, nil)

		return default if row_ptr_min == nil
			if block_given?
				return yield i
			else
				return default
			end
		end

		a = Array.new(col_count, 0)
		return a if row_ptr_min < 0

		row_ptr_max = get_next_row_ptr(i)

		(row_ptr_min...row_ptr_max).each do |j|
			a[@columns[j]] = @values[j]
		end 

		a
	end

	def get_next_row_ptr(index)
		return @values.size if index == row_count - 1

		i = 1
		next_ptr = @row_ptrs.fetch(index + i, -1)
		unless next_ptr >= 0
			i += 1
			next_ptr = @row_ptrs[index + i]
		end
		next_ptr
	end

	def get_arrays
		a = []
		row_count.times do |i|
			if block_given?
				a << yield(get_row(i))
			else
				a << get_row(i)
			end
		end
		a
	end

	def self.create(row_count, column_count = row_count)	
		values, columns, row_ptrs = [], [], []
		row_count.times do |i|
			first = -1
			column_count.times do |j|
				y = yield i, j
				if y != 0
					values << y
					columns << j
					first = values.size - 1 if first == -1
				end
			end
			row_ptrs << first
		end
		new values, columns, row_ptrs, column_count
	end

end