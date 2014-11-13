require 'test/unit'
require_relative 'board'

module Models
  class Player
    include Test::Unit::Assertions

    def initialize(tokens, pattern)
      pre_initialize(tokens, pattern)
      @tokens = tokens
      @pattern = pattern
      invariant
    end

    attr_accessor :pattern, :tokens

    def get_move(board)
      invariant
      pre_get_move(board)
      token, column = determine_move(board)
      post_get_move(board, token, column)
      invariant
      token, column
    end

    private
    def pre_initialize(tokens, pattern)
      assert tokens.respond_to?(:keys) && tokens.respond_to?(:key?) && tokens.respond_to(:size)
      assert pattern.respond_to?(:each) && pattern.respond_to?(:to_a) && pattern.respond_to(:size)
    end

    def pre_get_move(board)
      assert board.is_a? Board
    end

    def post_get_move(board, token, column)
      assert token.respond_to(:to_sym)
      assert column.respond_to(:to_i)
      assert !board.column_full?(column.to_i)
    end

    def invariant
      @tokens.size > 0
      @pattern.size > 0
    end

    def determine_move(board)
      raise 'VirtualError, please implement determine_move'
    end

  end
end