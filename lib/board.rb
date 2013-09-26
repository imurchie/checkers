require_relative "./piece"

module Checkers
  class InvalidMoveError < StandardError
    def initialize(start_pos, end_pos, message = "")
      super(message)

      @start_pos, end_pos = start_pos, end_pos
    end

    def to_s
      "Cannot move from #{@start_pos} to #{@end_pos}"
    end
  end


  class Board
    GRID_SIZE = 8 # extending to other sides requires some thinking

    def initialize(grid = nil)
      @grid = (grid ? grid : init_grid)
    end

    def move(start_pos, end_pos)
      if valid_move?
        move!(start_pos, end_pos)
      else
        raise InvalidMoveError(start_pos, end_pos)
      end
    end

    def move!
    end

    def [](row, col)
      @grid[row][col]
    end

    def on_board?(row, col)
      (row >= 0 && row < GRID_SIZE) && (col >= 0 && col < GRID_SIZE)
    end




    # for debugging in pry only
    def pb
      puts "  0 1 2 3 4 5 6 7"
      @grid.each_with_index do |row, index|
        print "#{index} "
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

    def valid_move?(start_pos, end_pos)
    end
  end
end
