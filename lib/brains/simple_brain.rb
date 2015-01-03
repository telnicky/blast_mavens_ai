class SimpleBrain < BrainBase
  attr_reader :current_direction

  STATES = {
    right: :down,
    down:  :left,
    left:  :up,
    up:    :right
  }.freeze

  def move
    next_direction
  end

  def next_direction
    if current_direction.nil?
      @current_direction = :right
    elsif !player.no_collision?(current_direction)
      @current_direction = STATES[current_direction]
    end

    current_direction
  end

  def bomb?
    true
  end
end
