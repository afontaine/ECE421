require 'test/unit'
require_relative '../data/model'
require_relative '../data/model/game_token'
require_relative '../data/model/game_board'
require_relative '../data/model/player'
require_relative '../data/controller'
require_relative '../data/controller/player_controller'

class PlayerControllerTest < Test::Unit::TestCase
  def setup
    @game = Model::GameBoard.new(7, 6)
    @controller = Controller::PlayerController.new(Model::Player.new({X: 21}, [:X] * 4))
  end

  def test_make_move
    assert_equal({X: 21}, @controller.tokens)
    @controller.make_move(@game, 1)
    assert_equal({X: 20}, @controller.tokens)
    asert_false(@game.win?(@controller.player.pattern))
    3.times { @game[0] = Model::GameToken.new(@controller.player) }
    @controller.make_move(@game, 0)
    assert_true(@game.win?(@controller.player.pattern))
  end
end