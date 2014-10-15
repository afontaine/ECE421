require 'contracts'

module ContractExtensions
	include Contracts

	class EnumerableOf < CallableClass
		def initialize(contract)
			@contract = contract
		end

		def valid?(vals)
			if vals.is_a? Hash
				vals.all? do |key ,val|
					res, _ = Contract.valid?(val, @contract)
					res
				end
			else
				vals.respond_to?(:each) && vals.all? do |val|
					res, _ = Contract.valid?(val, @contract)
					res
				end
			end
		end

		def to_s
			"Enumerable (:each) of #{@contract}"
		end
	end

	class RangeOrInt
		def valid?(val)
			return false unless val.respond_to? :each

			case val.size
			when 1
				val = val[0]
				val.respond_to?(:to_i) || (val.respond_to?(:min) && val.respond_to?(:max))
			when 2
				val.all? { |v| respond_to? :to_i }
			else
				false
			end
		end

		def to_s
			"Expected argument of size 1..2, of either a Range or Int"
		end
	end

end