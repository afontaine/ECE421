# taken from: 
# http://stackoverflow.com/questions/5513558/executing-code-for-every-method-call-in-a-ruby-module

module Invariant
	def self.invariant(klass, *names, &block)
		klass.send(:define_method, :invariant, &block)
		names -= [:invariant]
		names.each do |name|
			m = klass.instance_method(name)
			klass.send(:define_method, name) do |*args, &blk|
				self.send(:invariant)
				res = m.bind(self).call(*args, &blk)
				self.send(:invariant)
				res
			end
		end
	end
end