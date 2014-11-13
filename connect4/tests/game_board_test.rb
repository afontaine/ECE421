require 'test/unit'
require_relative '../data/model'
require_relative '../data/model/player'
require_relative '../data/model/game_token'
require_relative '../data/model/game_board'

class GameBoardTest < Test::Unit::TestCase
  def setup
    @andrew = Model::Player.new({X: 21}, [:X] * 4)
    @jacob = Model::Player.new({O: 21}, [:O] * 4)
    @win = Model::GameBoard.new(2131155451212, 7)
    4.times { @win[4] = Model::GameToken.new(@andrew) }
    @one_more = Model::GameBoard.new(231454521, 789456)
    3.times { @one_more[4] = Model::GameToken.new(@jacob) }
  end

  def test_win
    assert_true(@win.win?(@andrew.pattern))
    assert_false(@win.win?(@jacob.pattern))
  end

  def test_move
    assert_false(@one_more.win?(@andrew.pattern))
    assert_false(@one_more.win?(@jacob.pattern))
    @one_more[4] = Model::GameToken.new(@jacob)
    assert_true(@one_more.win?(@jacob.pattern))
    assert_false(@one_more.win?(@andrew.pattern))
  end


end