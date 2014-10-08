require 'contracts'
require 'test/unit'
require_relative '../contracts/contract_extensions'

class SparseHash < Hash
	include Contracts
	include ContractExtensions

 	attr_reader :size

	Contract RespondTo[:to_i], Any, Maybe[Func[Hash, Any => Any]] => SparseHash
	def initialize(size, default = nil, &block)
		@size = size.to_i
    	@default = block || Proc.new { default }
		super() { |h,k| k.between?(0, @size-1) ?  @default.call(h,k) : nil }
		self
 	end

 	Contract Any => Any
 	def default=(value)
    	@default = value.respond_to?(:call) ? value : Proc.new { value }
	end

 	alias_method :default_proc=, :default=

	Contract RespondTo[:to_i], Any => Any
	def []=(k,v)
		k = k.to_i
    	k += size if k < 0
    	return nil unless k.between?(0, size - 1)
		v == default_proc.call(self, k) ? delete(k) : super(k,v)
	end

	Contract RespondTo[:to_i] => Any
	def [](k)
		k = k.to_i
		k += size if k < 0
		super(k)
	end

	# Contract RespondTo[:to_i], RespondTo[:to_i] => SparseHash
	# def [](i, j)
	# 	i, j = i.to_i, j.to_i
	# 	i += size if i < 0
	# 	j += size if j < 0
	# 	return {} if
	# 	h = SparseHash.new(j - i)
	# end

	# Contract And[RespondTo[:max], RespondTo[:min]] => SparseHash
	# def [](range)
	# 	h = SparseHash.new(range.size, 0)
	# 	h.default_proc = &self.default_proc
	# end

	# alias_method :slice, :[]

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
			super() do |_, v|
				yield v
			end
		end
  	end

 	alias_method :collect, :map

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
			super() do |_, v|
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