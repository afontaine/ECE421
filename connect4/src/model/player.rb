require 'test/unit'

module Models
  class Player
    include Test::Unit::Assertions

    def initialize(tokens, pattern)
      pre_initialize(tokens, pattern)
      @tokens = tokens
      @pattern = win_pattern
      invariant
    end

    attr_accessor :pattern, :tokens

    private
    def pre_initialize(tokens, pattern)
      assert tokens.respond_to?(:each) && tokens.respond_to?(:to_a) && tokens.respond_to(:size)
      assert pattern.respond_to?(:each) && pattern.respond_to?(:to_a) && pattern.respond_to(:size)
    end

    def invariant
      @tokens.size > 0
      @pattern.size > 0
    end

  end
end