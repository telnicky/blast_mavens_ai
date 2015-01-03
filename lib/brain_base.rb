class BrainBase
  attr_reader :player

  def initialize(player)
    @player = player
  end

  def move
    raise NotImplementedError
  end

  def bomb?
    raise NotImplementedError
  end
end
