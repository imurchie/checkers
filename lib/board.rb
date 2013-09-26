require_relative "./piece"

module Checkers
  class InvalidMoveError < StandardError
    attr_reader :start_pos, :end_pos

    def initialize(start_pos, end_pos, message = "")
      super(message)

      @start_pos, @end_pos = start_pos, end_pos
    end

    def to_s
      "Cannot move from #{@start_pos} to #{@end_pos.inspect}"
    end
  end


  class Board
    GRID_SIZE = 8 # extending to other sides requires some thinking

    def initialize(grid = nil)
      @grid = (grid ? grid : init_grid)

      self
    end

    def move(start_pos, *end_pos)
      if end_pos.length == 1 && valid_slide_move?(start_pos, end_pos[0])
        # sliding move
        move!(start_pos, *end_pos)
      elsif end_pos.length > 1 && valid_jump_move?(start_pos, *end_pos)
        # jumping move
        move!(start_pos, *end_pos)
      else
        raise InvalidMoveError(start_pos, end_pos)
      end
    end

    def move!(start_pos, *end_pos)
      start_piece = self[*start_pos]

      self[*start_pos] = nil

      if end_pos.length == 1
        self[*end_pos[0]] = start_piece
        start_piece.set_position(*end_pos[0])
      else
        end_pos.each do |pos|
          # something
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


    private

    def init_grid
      grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE) {nil} }

      # populate grid
      (0...3).each do |row|
        (0...GRID_SIZE).each do |col|
          if (row.even? && col.odd?) || (row.odd? && col.even?)
            grid[row][col] = Piece.new(:red, self, [row, col])
          end
        end
      end

      (0...3).each do |row|
        (0...GRID_SIZE).each do |col|
          if ((7 - row).even? && col.odd?) || ((7 - row).odd? && col.even?)
            grid[7 - row][col] = Piece.new(:white, self, [7 - row, col])
          end
        end
      end

      grid
    end

    def valid_slide_move?(start_pos, end_pos)
      piece = self[*start_pos]
      piece.slide_moves.include?(end_pos)
    end

    def valid_jump_move?(start_pos, *end_pos)
      piece = self[*start_pos]
      end_pos.all? { |pos| piece.jump_moves.include?(pos) }
    end
  end
end
