require_relative "./board"
require_relative "./constants"

module Checkers
  class Game
    include Checkers::Constants

    INPUT_MAP = {
      "1" => 0, "2" => 1, "3" => 2, "4" => 3,
      "5" => 4, "6" => 5, "7" => 6, "8" => 7,
      "a" => 0, "b" => 1, "c" => 2, "d" => 3,
      "e" => 4, "f" => 5, "g" => 6, "h" => 7
    }

    def play
      players = [:red, :white]
      current = 0

      board = Board.new
      until board.game_over?
        print_board(board)
        begin
          move = get_move(players[current])
          start_pos = move.shift

          board.move(start_pos, *move, players[current])
        rescue InvalidMoveError => ex
          puts "Invalid move: #{ex.message}"
          next  # skip alternation of turn
        end

        # alternate each turn
        current = (current == 0 ? 1 : 0)
      end
    end


    private

    def get_move(color)
      puts "#{color.to_s.capitalize}: Enter a move (e.g., f3 h5 [f7...]): "
      input = gets.chomp.split(" ")

      input.map do |str|
        str.split("").map { |pos| INPUT_MAP[pos] }.reverse
      end
    end

    def print_board(board)
      puts "  a b c d e f g h"
      board.output.each_with_index do |row, index|
        print "#{index + 1} "
        row.each do |pos|
          print case pos
          when nil
            "_ "
          when :red
            "#{RED_PAWN} "
          when :red_king
            "#{RED_KING} "
          when :white
            "#{WHITE_PAWN} "
          when :white_king
            "#{WHITE_KING} "
          else
            raise "Board returned invalid output."
          end
        end
        puts
      end

      nil
    end
  end
end

Checkers::Game.new.play
