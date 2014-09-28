require 'contracts'

module SparseContracts
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
end