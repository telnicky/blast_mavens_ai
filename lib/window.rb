require "gosu"

class Window < Gosu::Window
  attr_accessor :delegate

  def initialize
    super(*Processor::Screen)
    self.caption = "Blast Mavens: Multiplayer Beta v0.1.0"
  end

  def draw
    delegate.draw if delegate
  end

  def update
    delegate.update if delegate
  end

  def button_down(id)
    delegate.button_down(id) if delegate
  end

  def method_missing(sym, *args, &block)
    delegate.public_send(sym, *args, &block) if delegate
  end
end
