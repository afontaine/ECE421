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

	Contract RespondTo[:to_i], Maybe[Func[Any => Any]] => Any
	def fetch(i)
		i = i.to_i
		self[i].nil? && block_given? ? yield(i) : self[i]
	end

	Contract Or[Bool, Func[Any => Any], nil] => Or[Enumerator, Array]
	def map(defaults = true)
		return to_enum :map unless block_given?
		if defaults
			size_arr.map do |i|
				yield self[i]
			end
		else
			super() do |k, v|
				yield v
			end
		end
	end

	Contract Or[Bool, Func[Any => Any], nil] => Or[Enumerator, SparseHash]
	def each_with_index(defaults = true)
		return to_enum :each_with_index, defaults unless block_given?
		if defaults
			size_arr.each do |i|
				yield self[i], i
			end
		else
			self.each_pair do |k, v|
				yield v, k
			end
		end
		self
	end

	Contract Or[Bool, Func[Any => Any], nil] => Or[Enumerator, SparseHash]
	def each(defaults = true)
		return to_enum :each, defaults unless block_given?
		if defaults
			size_arr.each do |i|
				yield self[i]
			end	
		else
			super() do |k, v|
				yield v
			end
		end
		self
	end

	Contract nil => Array
	def to_a
		Array.new(size) { |i| self[i].is_a?(SparseHash) ? self[i].to_a : self[i] }
	end

	def method_missing(name, *args, &block)
		to_a.send(name, *args, &block)
	end

	private

	def size_arr
		(0...size)
	end

end