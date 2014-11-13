require 'test/unit'
require_relative '../src/models'

class PlayerTest < Test::Unit::TestCase
  def test_player
    andrew = Models::Player.new({X: 21}, [:X] * 4)
    assert_equal({X: 21}, andrew.tokens)
    assert_equal([:X, :X, :X, :X], andrew.pattern)
  end

  def test_ai_move
    game = Models::Board.new(6, 7)
    player = Models::AIPlayer.new({O: 21}, [:O] * 4)
    token, column = player.get_move(game)
    assert_equal :O, token
    assert_equal 0, column
  end
end