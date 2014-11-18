require 'test/unit'
require 'gtk2'
require_relative '../models'

module Controllers
  class GameController
    include Test::Unit::Assertions

    def initialize(board, game_name,  player, opponent, builder, skin)
      pre_initialize(board, player, opponent)
      @board = board
      @player = player
      @opponent = opponent
      @builder = builder
      @skin = skin
      init_board
      init_buttons
      init_messages(game_name)
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
      set_board_token(token, column)
      player.tokens[token] -= 1
      post_make_move(player, token)
      invariant
    end

    def on_new_game_clicked(button)

    end

    def on_switch_game_clicked(button)

    end

    def on_token_clicked(button)
      token = button.label.to_sym
      column = button.builder_name[-2].to_i
      return unless valid_move?(token, column)
      set_board_token(token, column)
      @player.tokens[token] -= 1
      update_token_message
    end

    def on_game_window_destroy(*args)
      Gtk.main_quit
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

    def init_buttons
      @board.column_size.times do |i|
        j = 0
        @player.tokens.keys.each do |key|
          btn = @builder['button_' + i.to_s + j.to_s]
          set_button(btn, key)
          j += 1
        end
        (j...2).each do |k|
          btn = @builder['button_' + i.to_s + k.to_s]
          set_button(btn, :empty)
        end
      end
    end

    def init_messages(game)
      @builder['game_label'].label = 'Playing ' + game
      update_token_message
    end

    def update_token_message
      @builder['token_label'].label = @player.tokens.map do |k,v|
        "#{k}: #{v}"
      end.join("\n")
    end

    def set_button(button, token)
      if token == :empty
        button.set_property(:visible, false)
      else
        button.set_property(:visible, true)
        button.label = token.to_s
      end
    end

    def valid_move?(token, column)
      @player.tokens[token] > 0 && !@board.column_full?(column)
    end

    def set_board_token(token, column)
      row = @board.set(column, token)
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