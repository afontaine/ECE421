require 'test/unit'

class GameTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    @andrew = Model::Player.new("Andrew")
    @jacob = Model::Player.new("Jacob")
    @win = Model::Game([
        [nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil, nil],
        [Model::GameToken.new(@andrew), Model::GameToken.new(@andrew), Model::GameToken.new(@andrew),
         Model::GameToken.new(@andrew), nil, nil, nil],
    ])
    @one_more = Model::Game([
                                [nil, nil, nil, nil, nil, nil, nil],
                                [nil, nil, nil, nil, nil, nil, nil],
                                [nil, nil, nil, nil, nil, nil, nil],
                                [nil, nil, nil, nil, nil, nil, nil],
                                [nil, nil, nil, nil, nil, nil, nil],
                                [nil, nil, nil, nil, nil, nil, nil],
                                [Model::GameToken.new(@andrew), Model::GameToken.new(@andrew),
                                 Model::GameToken.new(@andrew), nil, nil, nil, nil],
                            ])
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  def test_win
    assert_true(@win.over?)
    assert_equal(@andrew, @win.winner)
  end

  def test_move
    assert_false(@one_more.over?)
    @one_more[4] = Model::GameToken.new(@andrew)
    assert_true(@one_more.over?)
    assert_equal(@andrew, @one_more.winner)
  end
end