module Checkers
  class Piece
    attr_reader :color, :row, :col

    def initialize(color, board, position)
      @color, @board = color, board

      @row = position[0]
      @col = position[1]

      # initial direction is based on starting position
      @direction = ((@row < Board::GRID_SIZE / 2) ? :+ : :-)
    end

    def slide_moves
      next_row = row.send(@direction, 1)

      moves = []
      move_offsets.each do |offset|
        moves << [next_row, col + offset] if board[next_row, col + offset] == nil
      end

      moves
    end

    def jump_moves
      sliding_moves = slide_moves

      moves = []
      #sliding_moves.
    end

    def to_s
      @color
    end

    def inspect
      to_s
    end

    private

    attr_reader :board, :direction

    def move_offsets
      [-1, 1].select do |offset|
        board.on_board?(row.send(direction, 1), col + offset)
      end
    end
  end
end
