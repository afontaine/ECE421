require 'test/unit'
require_relative '../src/models'

class BoardTest < Test::Unit::TestCase
  def setup
    @andrew = Model::Player.new({X: 21}, [:X] * 4)
    @jacob = Model::Player.new({O: 21}, [:O] * 4)
    @win = Model::Board.new(6, 7)
    4.times { @win[4] = :X }
    @one_more = Model::Board.new(6, 7)
    3.times { @one_more[4] = :O }
  end

  def test_win
    assert_true(@win.win?(@andrew.pattern))
    assert_false(@win.win?(@jacob.pattern))
  end

  def test_move
    assert_false(@one_more.win?(@andrew.pattern))
    assert_false(@one_more.win?(@jacob.pattern))
    @one_more[4] = :O
    assert_true(@one_more.win?(@jacob.pattern))
    assert_false(@one_more.win?(@andrew.pattern))
  end

  def test_invalid_column
    assert_raise(Model::IndexError) { @win[10] =:X }
    assert_raise(Model::ColumnFullError) { 10.times { win[4] = :X } }
    assert_nothing_raised { @win[3] = :X }
    assert_nothing_raised { 7.times { @win[0] = :O } }
  end
end