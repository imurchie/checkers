require_relative "./piece"

module Checkers
  class InvalidMoveError < StandardError
    attr_reader :start_pos, :end_pos

    def initialize(start_pos, end_pos, message = "")
      super(message)

      @start_pos, @end_pos = start_pos, end_pos
    end

    # def to_s
    #   "#{self.class}: Cannot move from #{@start_pos} to #{@end_pos.inspect}"
    # end
  end


  class Board
    GRID_SIZE = 8 # extending to other sides requires some thinking

    def initialize(grid = nil)
      @grid = (grid ? grid : init_grid)

      self
    end

    def move(start_pos, *end_pos, color)
      piece = self[*start_pos]

      if piece.nil?
        raise InvalidMoveError.new(start_pos, end_pos, "No piece.")
      elsif piece.color != color
        raise InvalidMoveError.new(start_pos, end_pos, "Not correct color.")
      end


      if valid_slide_move?(start_pos, *end_pos)
        move!(start_pos, *end_pos)
      elsif valid_jump_move?(start_pos, *(end_pos.dup))
        move!(start_pos, *end_pos)
      else
        raise InvalidMoveError.new(start_pos, end_pos)
      end
    end

    def move!(start_pos, *end_pos)
      piece = self[*start_pos]

      if slide_move?(start_pos, *end_pos)
        self[*start_pos] = nil
        self[*end_pos[0]] = piece
        piece.set_position(*end_pos[0])
      else
        current_pos = start_pos
        end_pos.each do |pos|
          self[*current_pos] = nil

          # get rid of jumped-over piece
          mid_pos = calculate_mid_position(current_pos, pos)

          self[*mid_pos] = nil

          self[*pos] = piece
          piece.set_position(*pos)

          # get set for next iteration
          current_pos = pos
        end
      end

      true
    end

    def [](row, col)
      @grid[row][col]
    end

    def []=(row, col, value)
      @grid[row][col] = value

      value
    end

    def on_board?(row, col)
      (row >= 0 && row < GRID_SIZE) && (col >= 0 && col < GRID_SIZE)
    end

    def game_over?
      # loop through and see if all of one or the other color is no longer present
      false
    end

    def dup
      new_board = Board.new

      new_grid = []
      @grid.each do |row|
        new_row = []
        row.each do |piece|
          new_row << (piece.nil? ? piece : piece.dup(new_board))
        end

        new_grid << new_row
      end

      new_board.grid = new_grid

      new_board
    end


    # for debugging in pry only
    def pb
      puts "  a b c d e f g h"
      @grid.each_with_index do |row, index|
        print "#{index + 1} "
        row.each do |col|
          print (col.nil? ? "_ " : (col.color == :red ? "r " : "w "))
        end
        puts
      end

      nil
    end


    protected

    def grid=(new_grid)
      @grid = new_grid
    end


    private

    def init_grid
      grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE) {nil} }

      # populate grid
      (0...3).each do |row|
        (0...GRID_SIZE).each do |col|
          if (row.even? && col.odd?) || (row.odd? && col.even?)
            grid[row][col] = Piece.new(:red, self, [row, col], [:+])
          end
        end
      end

      (0...3).each do |row|
        (0...GRID_SIZE).each do |col|
          if ((7 - row).even? && col.odd?) || ((7 - row).odd? && col.even?)
            grid[7 - row][col] = Piece.new(:white, self, [7 - row, col], [:-])
          end
        end
      end

      grid
    end

    def slide_move?(start_pos, *end_pos)
      piece = self[*start_pos]

      # a slide move only moves a single square
      (piece.row - end_pos[0][0]).abs == 1
    end

    # a slide move is valid only if there are no jump moves on the board
    # and the particular slide is to an empty place
    def valid_slide_move?(start_pos, *end_pos)
      piece = self[*start_pos]

      all_jump_moves(piece.color).empty? &&
      end_pos.length == 1 &&
      piece.slide_moves.include?(end_pos[0])
    end

    # expects an end_pos Array that can be destroyed
    def valid_jump_move?(start_pos, *end_pos)
      return true if end_pos.empty?

      board = self.dup
      piece = board[*start_pos]

      # get the next jump position
      # and see if it is in the jump positions for the piece
      pos = end_pos.shift
      if piece.jump_moves.include?(pos)
        board.move!([piece.row, piece.col], pos)

        # try the rest of the moves
        return valid_jump_move?(pos, *end_pos)
      else
        # we cannot do that move, so send false up the stack
        return false
      end
    end

    def all_jump_moves(color)
      moves = []
      @grid.each do |row|
        row.each do |piece|
          moves += piece.jump_moves if piece && piece.color == color
        end
      end

      moves
    end

    def calculate_mid_position(start_pos, end_pos)
      # there must be a better way to do this, but...
      new_row = start_pos[0] + ((start_pos[0] - end_pos[0] == 2) ? -1 : 1)
      new_col = start_pos[1] + ((start_pos[1] - end_pos[1] == 2) ? -1 : 1)

      [new_row, new_col]
    end
  end
end
