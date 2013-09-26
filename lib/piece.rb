module Checkers
  class Piece
    attr_reader :color, :row, :col

    def initialize(color, board, position, direction = nil)
      @color, @board = color, board

      @row = position[0]
      @col = position[1]

      # initial direction is based on starting position
      if direction
        @direction = direction
      else
        @direction = ((@row < Board::GRID_SIZE / 2) ? :+ : :-)
      end

    end

    def available_moves
      moves = jump_moves

      moves += slide_moves if moves.empty?

      moves
    end

    def slide_moves
      next_row = row.send(direction, 1)

      moves = []
      move_offsets(row, col).each do |offset|
        moves << [next_row, col + offset] if board[next_row, col + offset].nil?
      end

      moves
    end

    def jump_moves
      moves = []

      move_offsets(row, col).each do |offset|
        neighbor = board[row.send(direction, 1), col + offset]
        next if neighbor.nil? || neighbor.color == color

        row_n = neighbor.row.send(direction, 1)
        col_n = neighbor.col + offset
        if board.on_board?(row_n, col_n) && board[row_n, col_n].nil?
          moves << [row_n, col_n]
        end
      end

      moves
    end

    # def jump_moves(row = self.row, col = self.col)
    #   # base case: all movements are to empty spaces or occupied by us
    #   return [] if move_offsets(row, col).all? do |offset|
    #     neighbor = board[row.send(direction, 1), col + offset]
    #     neighbor.nil? || neighbor.color == color
    #   end

    #   moves = []
    #   move_offsets(row, col).each do |offset|
    #     neighbor = board[row.send(direction, 1), col + offset]
    #     next if neighbor.nil? || neighbor.color == color

    #     # the neighbor is an opponent!
    #     row_n = neighbor.row.send(direction, 1)
    #     col_n = neighbor.col + offset
    #     if board[row_n, col_n].nil?
    #       # the further side of the neighbor is empty
    #       moves << [row_n, col_n]
    #       moves += jump_moves(row_n, col_n)
    #     end
    #   end

    #   moves
    # end

    def set_position(row, col)
      @row = row
      @col = col
    end

    def to_s
      "Piece: #{color} @ (#{row}, #{col})"
    end

    def inspect
      to_s
    end

    def dup(new_board)
      Piece.new(color, new_board, [row, col], direction)
    end


    private

    attr_reader :board, :direction

    def move_offsets(row, col)
      [-1, 1].select do |offset|
        board.on_board?(row.send(direction, 1), col + offset)
      end
    end
  end
end
