#!/usr/bin/env ruby

require_relative "models"

class LogParser

  def initialize(log_file = nil, output = nil)
    @log_file = log_file
    @output = output
    @games = []
  end


  def parse
    log = self.read_game_log

    game_index = 1
    current_game = nil

    log.each do |line|
      if line.include?('InitGame:')
        current_game = Game.new(game_index)
        @games << current_game
        game_index += 1
      end

      if line.include?('Exit:') || line.include?('ShutdownGame:')
        current_game = nil
        next
      end

      if line.include?('ClientConnect:') && current_game
        player_id = line.split(': ')[1].strip
        current_game.add_player(player_id)
      end

      if line.include?('ClientDisconnect:') && current_game
        player_id = line.split(': ')[1].strip
        current_game.remove_player(player_id)
      end

      if line.include?('ClientUserinfoChanged:') && current_game
        player_line = line.split('n\\')
        player_id = player_line[0].split(': ')[1].strip
        player_name = player_line[1].split('\\t')[0].strip
        current_game.update_player_name(player_id, player_name)
      end

      if line.include?('Kill:')
        kill_line = line.split('killed ')
        player_ids = kill_line[0].split(': ')[1].split(' ')
        killer_id = player_ids[0].strip
        killed_id = player_ids[1].strip
        current_game.register_kill(killer_id, killed_id)
        kill_by_means = kill_line[1].split(' by')[1].strip
        current_game.register_kill_by_means(kill_by_means)
      end
    end
  end

  def print
    if @games.empty?
      puts 'No games found'
      exit
    end

    @games.each do |game|
      if @output == 'json'
        puts game.to_json
      else
        puts game.to_s
      end
    end
  end

  private

    def read_game_log
      if @log_file.nil?
        print_usage
        exit
      end

      if !File.exist?(@log_file)
        puts "File #{@log_file} not found\n\n"
        print_usage
        exit
      end

      File.read(@log_file).split("\n")
    end

    def print_usage
        puts "Usage: ./parser.rb <log_file> <output>"
        puts "Output options: json, text | Default: text\n\n"
        puts "Example: parser.rb qgames.log json\n\n"
    end

end

if __FILE__ == $0
  log_parser = LogParser.new(ARGV[0], ARGV[1])
  log_parser.parse
  log_parser.print
end
