require 'test/unit/assertions'
require 'gtk2'
require 'thread'
require_relative '../models'

module Controllers
  ACTION_NEW_GAME = 1
  ACTION_SWITCH_GAME = 2
  class GameController
    include Test::Unit::Assertions

    def initialize(game_name, builder, skin)
      @game_name = game_name
      @builder = builder
      @skin = skin
      @button_lock = Mutex.new
      start_connect_4 if game_name == :'Connect 4'
      start_otto_toot if game_name == :'OTTO TOOT'
      pre_initialize(@board, @player, @opponent)
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

    def start_connect_4
      @player = Models::Player.new({X: 21}, [:X] * 4)
      @opponent = Models::AIPlayer.new({O: 21}, [:O] * 4)
      @board = Models::Board.new(6, 7)
      init_messages(@game_name.to_s)
      init_board
      init_buttons
    end

    def start_otto_toot
      @player = Models::Player.new({T: 11, O: 10}, [:T, :O, :O, :T])
      @opponent = Models::AIPlayer.new({T: 10, O: 11}, [:O, :T, :T, :O])
      @board = Models::Board.new(6, 7)
      init_messages(@game_name.to_s)
      init_board
      init_buttons
    end

    def on_new_game_clicked(_button)
      start_connect_4 if @game_name == :'Connect 4'
      start_otto_toot if @game_name == :'OTTO TOOT'
    end

    def on_switch_game_clicked(_button)
      if @game_name == :'OTTO TOOT'
        @game_name = :'Connect 4'
        start_connect_4
      elsif @game_name == :'Connect 4'
        @game_name = :'OTTO TOOT'
        start_otto_toot
      end
    end

    def on_token_clicked(button)
      return if @button_lock.locked?
      @button_lock.synchronize do
        token = button.label.to_sym
        column = button.builder_name[-2].to_i
        return unless valid_move?(token, column)
        set_board_token(token, column)
        @player.tokens[token] -= 1
        update_token_message
        end_game if game_over
        return if game_over
        make_move(@opponent)
        end_game if game_over
      end
    end

    def game_over
      @board.win?(@player.pattern) || @board.win?(@opponent.pattern)
    end

    def end_game
      puts "You have lost" if @board.win?(@opponent.pattern)
      puts "You have won" if @board.win?(@player.pattern)
      end_dialog = Gtk::MessageDialog.new(@builder['game_window'],
        Gtk::Dialog::DESTROY_WITH_PARENT,
        Gtk::MessageDialog::INFO,
        Gtk::MessageDialog::BUTTONS_NONE,
        @board.win?(@player.pattern) ? 'You have won!' : 'You have lost!'
      )
      end_dialog.add_buttons(
          ['New Game', Controllers::ACTION_NEW_GAME],
          ['Switch Games', Controllers::ACTION_SWITCH_GAME],
          [Gtk::Stock::CLOSE, Gtk::Dialog::RESPONSE_CLOSE]
      )
      action = end_dialog.run
      case action
        when Controllers::ACTION_NEW_GAME
          on_new_game_clicked(nil)
        when Controllers::ACTION_SWITCH_GAME
          on_switch_game_clicked(nil)
        when Gtk::Dialog::RESPONSE_CLOSE
          Gtk::main_quit
        else
          on_new_game_clicked(nil)
      end
      end_dialog.destroy

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
      @builder['game_label'].label = "Playing #{game}\nWin pattern: #{@player.pattern.map(&:to_s).join(', ')}"
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