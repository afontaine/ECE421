require 'test/unit'

class GameControllerTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @andrew = Models::AIPlayer.new({O: 21}, [:O] * 4)
    @jacob = Models::AIPlayer.new({X: 21}, [:X] * 4)
    @board = Models::Board.new(6, 7)
  end

  def test_fail
    controller = Controllers::GameController.new(@board, @andrew, @jacob)
    controller.make_move(@andrew)
    assert_equal(20, @andrew.tokens[:O])
  end
end