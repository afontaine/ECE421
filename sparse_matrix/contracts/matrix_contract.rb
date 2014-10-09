require 'contracts'
require_relative 'contract_extensions'

module MatrixContract

	def self.included(base)
		base.extend(ClassContract)
	end


	def row_count
		raise 'Virtual method called. Please implement method'
	end

	def column_count
		raise 'Virtual method called. Please implement method'
	end

	def [](i, j)
		raise 'Virtual method called. Please implement method'
	end

	def []=(i, j, v)
		raise 'Virtual method called. Please implement method'
	end

	def row(i)
		raise 'Virtual method called. Please implement method'
	end

	def column(j)
		raise 'Virtual method called. Please implement method'
	end

	module ClassContract

		def rows(rows, column_count)
			raise 'Virtual method called. Please implement method'
		end

		def build(row_count, column_count)
			raise 'Virtual method called. Please implement method'
		end
	end
end


