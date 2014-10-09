require 'contracts'
require 'test/unit'
require_relative '../contracts/contract_extensions'

class SparseHash < Hash

 	attr_reader :size

	def initialize(size, default = nil, &block)
		@size = size
    	@default = block || Proc.new { default }
		super() { |h,k| k.between?(0, @size-1) ?  @default.call(h,k) : nil }
		self
 	end

 	def default=(value)
    	@default = value.respond_to?(:call) ? value : Proc.new { value }
	end

 	alias_method :default_proc=, :default=

	def []=(k,v)
		v == default_proc.call(self, k) ? delete(k) : super(k,v)
	end

	def fetch(i)
		self[i].nil? && block_given? ? yield(i) : self[i]
	end

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