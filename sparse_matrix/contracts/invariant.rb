# taken from: 
# http://stackoverflow.com/questions/5513558/executing-code-for-every-method-call-in-a-ruby-module

module Invariant
	def invariant(*names, &block)
		define_method(:invariant, &block)
		names -= [:invariant]
		names.each do |name|
			m = instance_method(name)
			define_method(name) do |*args, &blk|
				self.send(:invariant)
				res = m.bind(self).call(*args, &blk)
				self.send(:invariant)
				res
			end
		end
	end
end