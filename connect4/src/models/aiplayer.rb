require_relative 'player'

module Models

  def AIPlayer < Models::Player

    private
    def determine_move(board)
      # Jacob's pattented First-Avail-Column AI (TM)
      token = @tokens.first.first
      column = -1
      board.column_size.times do |j|
        unless board.column_full?(j)
          column = j
          break
        end
      end
      token, column
    end
  end

end