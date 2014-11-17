require 'test/unit'
require_relative '../src/models'

class BoardTest < Test::Unit::TestCase
  def setup
    @andrew = Models::Player.new({X: 21}, [:X] * 4)
    @jacob = Models::Player.new({O: 21}, [:O] * 4)
    @win = Models::Board.new(6, 7)
    4.times { @win[4] = :X }
    @one_more = Models::Board.new(6, 7)
    3.times { @one_more[4] = :O }
  end

  def test_win
    assert_true(@win.win?(@andrew.pattern))
    assert_false(@win.win?(@jacob.pattern))
    board = Models::Board.new(6, 7)
    4.times { |i| board[i] = :X }
    assert_true(board.win?(@andrew.pattern))
    board = Models::Board.new(6, 7)
    4.times do |i|
      i.times { board[i] = :O }
      board[i] = :X
    end
    assert_true(board.win?(@andrew.pattern))
  end

  def test_move
    assert_false(@one_more.win?(@andrew.pattern))
    assert_false(@one_more.win?(@jacob.pattern))
    @one_more[4] = :O
    assert_true(@one_more.win?(@jacob.pattern))
    assert_false(@one_more.win?(@andrew.pattern))
  end

  def test_invalid_column
    assert_raise(Models::IndexError) { @win[10] = :X }
    assert_raise(Models::ColumnFullError) { 10.times { @win[4] = :X } }
    assert_nothing_raised { @win[3] = :X }
    assert_nothing_raised { 6.times { @win[0] = :O } }
  end
end