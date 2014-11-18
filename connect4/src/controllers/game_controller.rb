require 'test/unit'
require 'gtk2'
require_relative '../models'

module Controllers
  class GameController
    include Test::Unit::Assertions

    def initialize(board, player, opponent, builder, skin)
      pre_initialize(board, player, opponent)
      @board = board
      @player = player
      @opponent = opponent
      @builder = builder
      @skin = skin
      init_board
      invariant
    end

    def game
      while !@board.win?(@player.pattern) || !@board.win?(@opponent.pattern) do
        make_move(@player)
        break if @observers.each(&:update)
        make_move(@opponent)
        break if @observers.any?(&:update)
      end
    end

    def add_observer(observer)
      @observers ||= []
      @observers << observer
    end

    def make_move(player)
      invariant
      pre_make_move(player)
      token, column = player.get_move(@board)
      @board[column] = token
      player.tokens[token] -= 1
      post_make_move(player, token)
      invariant
    end

    private
    def pre_initialize(board, player, opponent)
      assert board.is_a? Models::Board
      assert player.is_a?  Models::Player
      assert opponent.is_a?  Models::Player
    end

    def init_board
      @board.row_size.times do |i|
        @board.column_size.times do |j|
          @builder['token_' + i.to_s + j.to_s].file = @skin[:empty]
        end
      end
    end

    def set_board_token(token, row, column)
      @board[column] = token
      @builder['token_' + row.to_s + column.to_s].file = @skin[token]
    end

    def pre_make_move(player)
      token_available = player.tokens.any? { |_, val| val > 0 }
      slot_available = @board.board.any? { |col| col.any? { |v| v.nil? } }
      assert token_available && slot_available
    end

    def post_make_move(player, token)
      assert player.tokens[token] >= 0
    end

    def invariant
      @player.tokens.all? do |key, val|
        assert key.respond_to? :to_sym
        assert val >= 0
      end
    end

  end

end