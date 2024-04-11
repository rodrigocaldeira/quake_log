require 'json'

class Game
  attr_accessor :id, :players, :total_kills, :kills_by_means

  def initialize(id)
    @id = id
    @players = []
    @total_kills = 0
    @kills_by_means = Hash.new(0)
  end

  def add_player(player_id)
    player = Player.new(player_id)
    @players << player
  end

  def update_player_name(player_id, player_name)
    player = @players.find { |player| player.id == player_id }
    player.name = player_name
  end

  def remove_player(player_id)
    @players.delete_if { |player| player.id == player_id }
  end

  def register_kill(killer_id, killed_id)
    killer = @players.find { |player| player.id == killer_id }
    killed = @players.find { |player| player.id == killed_id }

    if killer && killer_id != killed_id
      killer.kills += 1
    end

    if killer_id == '1022' || killer_id == killed_id
      killed.kills -= 1
    end

    @total_kills += 1
  end

  def register_kill_by_means(kill_by_means)
    @kills_by_means[kill_by_means] += 1
  end

  def to_s
    puts '----------------------------------------'
    puts "Game #{self.id}"

    if self.players.empty?
      puts 'No players left'
      puts "----------------------------------------\n\n"
      return
    end

    puts 'Total kills: ' + self.total_kills.to_s
    puts "\n"

    puts 'Score:'
    self.players.sort_by{ |player| -player.kills}.each do |player|
      puts "\t#{player.kills}\t\t#{player.name}"
    end

    puts "\n"

    puts 'Kills by means:'
    self.kills_by_means.each do |key, value|
      puts "\t#{value}\t\t#{key}"
    end

    puts "----------------------------------------\n\n"
  end

  def as_json
    {
      id: self.id,
      total_kills: self.total_kills,
      players: self.players.map { |player| player.as_json },
      kills_by_means: self.kills_by_means
    }
  end

  def to_json
    JSON.generate(self.as_json)
  end
end

class Player
  attr_accessor :id, :name, :kills

  def initialize(id)
    @id = id
    @name = nil
    @kills = 0
  end

  def as_json
    {
      id: self.id,
      name: self.name,
      kills: self.kills
    }
  end
end
