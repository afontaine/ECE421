require 'test/unit'

class GameControllerTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @andrew = Models::Player.new({O: 21}, [:O] * 4)
    @jacob = Models::Player.new({X: 21}, [:X] * 4)
    @board = Models::Board.new(6, 7)
  end

  def test_fail

    fail('Not implemented')
  end
end