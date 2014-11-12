require 'test/unit'

class PlayerTest < Test::Unit::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown
    # Do nothing
  end

  # Fake test
  def test_player
    andrew = Model::Player("Andrew", "FF0000")
    assert_equal("Andrew", andrew.name)
    assert_equal("FF0000", andrew.color)
  end
end