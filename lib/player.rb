class Player

  attr_reader :bombs, :explosions, :x, :y, :index, :max_bombs, :tile_size, :facing, :animation_sprites, :movement_ctl, :image_counter,
    :image_index, :speed

  def initialize(player_number, brain_class)
    @max_bombs    = 3
    @speed        = 4
    @index        = player_number || 0
    @tile_size    = Processor::TileSize
    @facing       = :down
    @animation_sprites = {:left  => Gosu::Image.load_tiles(Processor.window, BLAST_IMG_PATH + "player_left#{ index }.png", tile_size, tile_size, false),
                          :down  => Gosu::Image.load_tiles(Processor.window, BLAST_IMG_PATH + "player_down#{ index }.png", tile_size, tile_size, false),
                          :up    => Gosu::Image.load_tiles(Processor.window, BLAST_IMG_PATH + "player_up#{ index }.png", tile_size, tile_size, false),
                          :right => Gosu::Image.load_tiles(Processor.window, BLAST_IMG_PATH + "player_right#{ index }.png", tile_size, tile_size, false)}
    @bombs        = []
    @explosions   = []
    @movement_ctl = { :left  => [[-1, 0], [0, 0, 0, 40]],
                      :right => [[1, 0], [40, 0, 40, 40]],
                      :up    => [[0, -1], [40, 0, 0, 0]],
                      :down  => [[0, 1], [40, 40, 0, 40 ]]}
    @image_counter = 0
    @image_index   = 4

    @x = @y = [tile_size * 1 + 1, tile_size * 14 + 1][index]
    @brain = brain_class.new(self)
  end

  def draw
    animation_sprites[facing][image_index].draw(@x, @y, 2)
  end

  def update
    movement!
    bombs!
  end

  def not_solid_at?(x, y)
    !Processor.solid_at?(x, y) && !Processor.all_bombs.detect{|bomb| bomb.solid_at?(x, y)}
  end

  # projecting coordinates where player end up if decised to move given direction
  #FIXME: fix out balanced speed, move gap etc
  def no_collision?(direction)
    target_x1 = @x + movement_ctl[direction].first[0] + movement_ctl[direction].last[0]
    target_x2 = @x + movement_ctl[direction].first[0] + movement_ctl[direction].last[2]
    target_y1 = @y + movement_ctl[direction].first[1] + movement_ctl[direction].last[1]
    target_y2 = @y + movement_ctl[direction].first[1] + movement_ctl[direction].last[3]
    not_solid_at?(target_x1, target_y1) && not_solid_at?(target_x2, target_y2)
  end

private
  def movement!
    image_counter_inc
    move_direction = @brain.move
    if move_direction
      @image_index = 0 unless (0..2).include?(image_index)
      @image_index += 1 if image_counter % 5 == 0
      speed.times do |i|
        if no_collision?(move_direction)
          update_bomb_solidness
          @x += movement_ctl[move_direction].first[0]
          @y += movement_ctl[move_direction].first[1]
          @facing = move_direction
        end
      end
    else
      @image_index = 4
    end
  end

  def drop_bomb
    @bombs << Bomb.new(center_x, center_y)
  end

  def bomb_present?
    bombs.detect {|bomb| bomb.at?(center_x, center_y)}
  end

  def bombs!
    if bomb? && !bomb_present?
      drop_bomb
    end
    check_bomb_existance
    check_explosion_existance
  end

  def check_bomb_existance
    bombs.reject! do |bomb|
      if bomb.time_counter == 0
        explode_bomb(bomb: bomb)
        explode_direction(bomb.top_x, bomb.top_y, :right)
        explode_direction(bomb.top_x, bomb.top_y, :left)
        explode_direction(bomb.top_x, bomb.top_y, :up)
        explode_direction(bomb.top_x, bomb.top_y, :down)
        true
      end
    end
  end

  def check_explosion_existance
    explosions.reject! { |explosion| explosion.time_counter == 0}
  end

  def center_x
    @x + 24
  end

  def center_y
    @y + 24
  end

  def explode_bomb(bomb: nil, x: nil, y: nil)
    if bomb
      @explosions << Explosion.new(bomb.top_x, bomb.top_y)
    elsif x && y
      @explosions << Explosion.new(x, y)
    end
  end

  def explode_direction(x,y, direction)
    [tile_size, tile_size*2].each do |inc|
      case direction
      when :right then new_x, new_y = x + inc, y
      when :left  then new_x, new_y = x - inc, y
      when :down  then new_x, new_y = x, y + inc
      when :up    then new_x, new_y = x, y - inc
      end

      break if Processor.solid_at?(new_x, new_y)
      explode_bomb(x: new_x, y: new_y)
    end
  end

  def image_counter_inc
    @image_counter += 1
  end

  def update_bomb_solidness
    bombs.each do |bomb|
      bomb.solid = true unless bomb.solid || bomb.at?(center_x, center_y)
    end
  end

  def bomb?
    @brain.bomb? && max_bombs > bombs.count
  end
end
