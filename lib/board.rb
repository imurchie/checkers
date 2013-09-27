require_relative "./piece"
require_relative "./errors"
require_relative "./error_handler"

module Checkers
  class Board
    include ErrorHandler

    GRID_SIZE = 8 # extending to other sides requires some thinking

    def self.on_board?(row, col)
      (row >= 0 && row < GRID_SIZE) && (col >= 0 && col < GRID_SIZE)
    end

    def initialize(grid = nil)
      @grid = (grid ? grid : init_grid)

      self
    end

    def move(start_pos, *end_pos, color)
      reset_errors
      piece = self[*start_pos]

      if piece.nil?
        add_error("No piece at initial position")
      elsif piece.color != color
        add_error("Incorrect piece at initial position")
      end


      if slide_move?(start_pos, end_pos.first)
        if valid_slide_move?(start_pos, end_pos.first)
          move!(start_pos, *end_pos)
        else
          add_error("Invalid sliding move")
        end
      else
        if valid_jump_move?(start_pos, *(end_pos.dup))
          move!(start_pos, *end_pos)
        else
          add_error("Invalid jumping move")
        end
      end

      return false if errors?
    end

    def perform_slide_move!(start_pos, end_pos)
      piece = self[*start_pos]

      unless slide_move?(start_pos, end_pos)
        raise InvalidMoveError.new(start_pos, end_pos, "Not a slide move!")
      end

      self[*start_pos] = nil
      self[*end_pos[0]] = piece
      piece.set_position(*end_pos[0])
    end

    def move!(start_pos, *end_pos)
      piece = self[*start_pos]

      if slide_move?(start_pos, *end_pos)

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

      # promote if it has reached the end
      piece.make_king if piece.row == 0 || piece.row == 7

      true
    end

    def [](row, col)
      @grid[row][col]
    end

    def []=(row, col, value)
      @grid[row][col] = value

      value
    end

    def game_over?
      lost?(:red) || lost?(:white)
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

    def output
      output = []

      @grid.each do |row|
        new_row = []
        row.each do |piece|
          if piece.nil?
            new_row << nil
          elsif piece.king?
            new_row << (piece.color == :red ? :red_king : :white_king)
          else
            new_row << piece.color
          end
        end

        output << new_row
      end

      # this is now an array that represents the data
      # but does not expose any of the internals
      output
    end


    protected

    def grid=(new_grid)
      @grid = new_grid
    end

    # expects an end_pos Array that can be destroyed
    def valid_jump_move?(start_pos, *end_pos)
      board = self.dup
      piece = board[*start_pos]

      if end_pos.empty?
        return piece.jump_moves.empty?
      end

      # get the next jump position
      # and see if it is in the jump positions for the piece
      pos = end_pos.shift
      if piece.jump_moves.include?(pos)
        board.move!([piece.row, piece.col], pos)

        # try the rest of the moves
        return board.valid_jump_move?(pos, *end_pos)
      else
        # we cannot do that move, so send false up the stack
        return false
      end
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
      end_pos.length == 1 && (piece.row - end_pos.first[0]).abs == 1
    end

    def valid_slide_move?(start_pos, end_pos)
      piece = self[*start_pos]

      all_jump_moves(piece.color).empty? &&
      piece.slide_moves.include?(end_pos)
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

    def lost?(color)
      # loop through and see if all of one or the other color cannot move
      !@grid.any? do |row|
        row.any? do |piece|
          piece && piece.color == color && piece.available_moves.empty?
        end
      end
    end
  end
end
