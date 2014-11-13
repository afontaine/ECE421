require 'test/unit'
require_relative '../src/model/player'

class PlayerTest < Test::Unit::TestCase
  def test_player
    andrew = Model::Player.new({X: 21}, [:X] * 4)
    assert_equal({X: 21}, andrew.tokens)
    assert_equal([:X, :X, :X, :X], andrew.pattern)
  end

  def test_ai_move
    game = Models::Board(6, 7)
    player = Models::AIPlayer.new({O: 21}, [:O] * 4)
    player.get_move(game)
    assert_equal(20, player.tokens[:O])
  end
end