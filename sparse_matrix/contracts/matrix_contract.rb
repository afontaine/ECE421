require 'contracts'
require_relative 'contract_extensions'

module MatrixContract

	def self.included(base)
		base.send(:include, InstanceContract)
		base.extend(ClassContract)
	end

	module InstanceContract
	  include Contracts
	  include ContractExtensions

		Contract nil => Num
	  	def row_count
	  		raise 'Virtual method called. Please implement method'
	  	end

	  	Contract nil => Num
	  	def column_count
	  		raise 'Virtual method called. Please implement method'
	  	end

		Contract RespondTo[:to_i] => Any
		def [](i, j)
			raise 'Virtual method called. Please implement method'
		end

		Contract RespondTo[:to_i], RespondTo[:to_i], Any => Any
		def []=(i, j, v)
			raise 'Virtual method called. Please implement method'
		end

		Contract RespondTo[:to_i] => Maybe[Vector]
		def row(i)
			raise 'Virtual method called. Please implement method'
		end

		Contract RespondTo[:to_i] => Maybe[Vector]
		def column(j)
			raise 'Virtual method called. Please implement method'
		end
	end

	module ClassContract
	  include Contracts
	  include ContractExtensions

		Contract EnumerableOf[RespondTo[:each]], Maybe[RespondTo[:to_i]] => Matrix
		def rows(rows, column_count = rows[0].size)
			raise 'Virtual method called. Please implement method'
		end

		Contract RespondTo[:to_i], Maybe[RespondTo[:to_i]], Maybe[Func[Any => Any]] => Or[Enumerator, Matrix]
		def build(row_count, column_count = row_count)
			raise 'Virtual method called. Please implement method'
		end
	end
end


