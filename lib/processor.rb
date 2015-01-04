require 'tileable'
require 'solid_tile'
require 'window'
require 'map'
require 'explosion'
require 'bomb'
require 'player'
require 'brain_base'

Dir.glob(BLAST_LIB_ROOT + 'windows/*.rb').each{|file| require file}
Dir.glob(BLAST_LIB_ROOT + 'brains/*.rb').each{|file| require file}

# Processor is responsible to keep overall configuration knowledge, state
# transitions and keeping track of windows
class Processor
  Width = 1024
  Height = 768
  Screen = [Width, Height, false]
  TileSize = 48

  class << self
    attr_reader :window
    attr_accessor :players

    def new
      @players = []
      @players << Player.new(0, SimpleBrain)
      @players << Player.new(1, BasicBrain)
      window.show
    end

    def center_map
      @center_map ||= {}.tap do |center_coords|
        (0...Height).each_slice(TileSize) do |coords_range|
          center_coords[coords_range[TileSize / 2]] = coords_range
        end
      end
    end

    def center_for(x, y)
      [center_for_coord(x), center_for_coord(y)]
    end

    def center_for_coord(coord)
      center = center_map.detect{ |_, coords| coords.include?(coord) }
      center && center.first
    end

    def all_bombs
      players.map {|p| p.bombs}.flatten
    end

    def game_over(death_toll)
      window.delegate = GameOver.new(window, death_toll)
    end

    def close
      window.close
    end

    def solid_at?(x,y)
      window.map ? window.map.solid_at?(x,y) : false
    end

    def window
      @window ||= Window.new.tap do |window|
        window.delegate = Game.new(window)
      end
    end
  end
end

