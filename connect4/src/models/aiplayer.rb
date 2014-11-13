require_relative 'player'

module Models

  class AIPlayer < Player

    private
    def determine_move(board)
      # Jacob's pattented First-Avail-Column AI (TM)
      token = @tokens.select { |_, val| val > 0 }.first.first
      column = -1
      board.column_size.times do |j|
        unless board.column_full?(j)
          column = j
          break
        end
      end
      return token, column
    end
  end

end