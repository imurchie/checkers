module Checkers
  class Piece
    attr_reader :color, :row, :col

    def initialize(color, board, position, directions)
      @color, @board = color, board

      @row = position[0]
      @col = position[1]

      @directions = directions

    end

    def available_moves
      moves = jump_moves

      moves += slide_moves if moves.empty?

      moves
    end

    def slide_moves
      moves = []

      directions.each do |dir|
        next_row = row.send(dir, 1)

        move_offsets(row, col).each do |offset|
          if board.on_board?(next_row, col + offset) && board[next_row, col + offset].nil?
            moves << [next_row, col + offset]
          end
        end
      end

      moves
    end

    def jump_moves
      moves = []

      directions.each do |dir|
        move_offsets(row, col).each do |offset|
          next_row = row.send(dir, 1)
          next unless board.on_board?(next_row, col + offset)

          neighbor = board[next_row, col + offset]
          next if neighbor.nil? || neighbor.color == color

          row_n = neighbor.row.send(dir, 1)
          col_n = neighbor.col + offset
          if board.on_board?(row_n, col_n) && board[row_n, col_n].nil?
            moves << [row_n, col_n]
          end
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
      Piece.new(color, new_board, [row, col], directions)
    end


    private

    attr_reader :board, :directions

    def move_offsets(row, col)
      offsets = []
      directions.each do |dir|
        offsets += [-1, 1].select do |offset|
          board.on_board?(row.send(dir, 1), col + offset)
        end
      end

      offsets
    end
  end
end
