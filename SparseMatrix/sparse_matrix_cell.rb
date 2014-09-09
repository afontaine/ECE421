class SparseMatrixCell
	@value = 0
	def initialize(row, column)
		@row = row
		@column = column
	end

	def initialize(row, column, value)
		@row = row
		@column = column
		@value = value
	end

	attr_accessor :value
	attr_accessor :row
	attr_accessor :column
end
