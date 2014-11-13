require 'test/unit'
require_relative '../src/models/player'

class PlayerTest < Test::Unit::TestCase
  def test_player
    andrew = Model::Player.new({X: 21}, [:X] * 4)
    assert_equal({X: 21}, andrew.tokens)
    assert_equal([:X, :X, :X, :X], andrew.pattern)
  end
end