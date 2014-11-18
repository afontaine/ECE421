require 'test/unit'
require_relative 'errors'

module Models
  class Board
    include Test::Unit::Assertions

    def initialize(rows, columns)
      pre_initialize(rows, columns)
      @row_size = rows.to_i
      @column_size = columns.to_i
      @board = Array.new(@column_size) { Array.new(@row_size) }
      invariant
    end

    attr_reader :row_size, :column_size

    def each(&block)
      invariant
      return to_enum :each unless block_given?

      @board.each do |column|
        column.each(&block)
      end
      invariant
    end

    def board
      @board.reduce([]) { |arr, col| arr << col.dup; arr }
    end

    def get(row, column)
      invariant
      pre_get(row, column)
      value = @board[column.to_i][row.to_i]
      invariant
      value
    end
    alias_method :[], :get

    def set(column, token)
      invariant
      pre_set(column, token)
      column = column.to_i
      token = token.to_sym
      row = next_available_row(column)
      @board[column][row] = token
      post_set(column, token)
      invariant
      row
    end
    alias_method :[]=, :set

    def win?(pattern)
      return true if @board.any? { |a| a.each_cons(4).any? { |a| a == pattern } }
      return true if each_row.any? { |r| r.each_cons(4).any? { |r| r == pattern } }
      return true if each_diagonal_up.any? { |d| d.each_cons(4).any? { |d| d == pattern } }
      return true if each_diagonal_down.any? { |d| d.each_cons(4).any? { |d| d == pattern } }
      false
    end

    def each_row
      invariant
      return to_enum :each_row unless block_given?
      @row_size.times do |i|
        row =  @column_size.times.reduce([]) do |row, j|
          row << get(i, j)
        end
        yield row
      end
      invariant
    end

    def each_diagonal_up
      invariant
      return to_enum :each_diagonal_up unless block_given?
      @column_size.times do |j|
        diag = (j...@column_size).zip(0...@row_size).reduce([]) do |diag, x|
          diag << get(x[1], x[0])
        end
        yield diag
      end
      @row_size.times do |i|
        diag = (i...@row_size).zip(0...@column_size).reduce([]) do |diag, x|
          diag << get(x[0], x[1])
        end
        yield diag
      end
      invariant
    end

    def each_diagonal_down
      invariant
      return to_enum :each_diagonal_down unless block_given?
      @column_size.times do |j|
        diag = (j.downto(0)).zip(0...row_size).reduce([]) do |diag, x|
          diag << get(x[1], x[0])
        end
        yield diag
      end
      @row_size.times do |i|
        diag = (i...@row_size).zip((column_size - 1).downto(0)).reduce([]) do |diag, x|
          diag << get(x[0], x[1])
        end
        yield diag
      end
      invariant
    end

    def column_full?(column)
      invariant
      pre_column_full(column)
      value = !@board[column.to_i].last.nil?
      invariant
      value
    end

    private

    def next_available_row(column)
      @board[column].index { |x| x.nil? }
    end

    def pre_get(row, column)
      assert row.respond_to?(:to_i) && column.respond_to?(:to_i)
      raise IndexError unless (row.to_i.abs.between?(0, @row_size - 1)) && (column.to_i.abs.between?(0, @column_size - 1))
    end

    def pre_set(column, token)
      raise ColumnFullError if column_full?(column)
      assert token.respond_to? :to_sym
      raise IndexError unless column.to_i.abs.between?(0, @column_size - 1)
    end

    def post_set(column, token)
      other = @board[column].select { |x| !x.nil? }.last
      assert token == other
    end

    def pre_column_full(column)
      assert column.respond_to? :to_i    
      raise IndexError unless column.to_i.abs.between?(0, @column_size - 1)
    end

    def pre_initialize(rows, columns)
      assert rows.respond_to?(:to_i) && columns.respond_to?(:to_i)
      rows, columns = rows.to_i, columns.to_i
      assert rows > 0 && columns > 0
    end

    def invariant
      assert @column_size > 0
      assert @row_size > 0
      assert @board.size == @column_size
      assert @board[0].size == @row_size
    end

  end

end