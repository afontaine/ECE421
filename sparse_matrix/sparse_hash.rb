require 'contracts'
require 'test/unit'
require_relative 'contracts/sparse_contracts'

class SparseHash < Hash
	include Contracts
	include SparseContracts

	Contract RespondTo[:to_i], Any, Maybe[Func[Hash, Any => Any]] => SparseHash
	def initialize(size, default = nil)
		@size = size.to_i

		if default
			super() { |h,k| k.between?(0, @size-1) ? default : nil }
		elsif block_given?
			super() { |h,k| k.between?(0, @size-1) ?  yield(h,k) : nil }
		else
			super()
		end
		self
	end

	Contract nil => Num
	def size
		@size
	end

	Contract RespondTo[:to_i], Any => Any
	def []=(k,v)
		k = k.to_i
		super(k, v) if k.between?(0, size-1)
	end

	Contract RespondTo[:to_i] => Any
	def [](k)
		k = k.to_i
		k += size if k < 0
		super(k)
	end

	def map
		return to_enum :map unless block_given?
		(0...size).map do |i|
			yield self[i]
		end
	end

end