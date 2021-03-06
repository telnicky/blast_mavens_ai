class Menu
  def initialize(window, opts={})
    @window     = window
    @pointer    = Gosu::Image.new(@window,BLAST_IMG_PATH + "cursor.png",true)
    @background = Gosu::Image.load_tiles(@window, BLAST_IMG_PATH + 'menu.png', 1024, 768, true).first
    @title      = Gosu::Image.load_tiles(@window, BLAST_IMG_PATH + 'title.png', 350, 80, true)
    @new_game   = Gosu::Image.load_tiles(@window, BLAST_IMG_PATH + 'newgame.png', 150, 40, true)
    @options    = Gosu::Image.load_tiles(@window, BLAST_IMG_PATH + 'options.png', 150, 40, true)
    @exit_game  = Gosu::Image.load_tiles(@window, BLAST_IMG_PATH + 'exitgame.png', 150, 40, true)
    @song       = Gosu::Song.new(@window, BLAST_SND_PATH + 'menu.wav')
    @new_game_index = @options_index = @exit_game_index = 1
    @song.play(true)
    @song.volume = 0.3
    @px = @py = 0
  end

  def update
    @px, @py = @window.mouse_x, @window.mouse_y
    update_hovers
  end

  def draw
    @background.draw(0,0,0)
    @title.first.draw(340, 190, 1)
    @new_game[@new_game_index].draw(450, 280, 1)
    @options[@options_index].draw(450, 330, 1)
    @exit_game[@exit_game_index].draw(450, 380, 1)
    @pointer.draw(@px,@py,2)
  end

  def button_down(id)
     Processor.close         if id == Gosu::KbEscape
     start_game              if id == Gosu::KbReturn
     mouse_clicked(@px, @py) if id == Gosu::MsLeft
     @song.volume -= 0.1     if id == Gosu::KbNumpadSubtract
     @song.volume += 0.1     if id == Gosu::KbNumpadAdd
   end

private

  def mouse_clicked(x, y)
    start_game if at_new_game?(x,y)
    Processor.close if at_exit_game?(x,y)
  end

  def update_hovers
     @new_game_index = at_new_game?(@px, @py) ? 0 : 1
     @options_index = at_options?(@px, @py) ? 0 : 1
     @exit_game_index = at_exit_game?(@px, @py) ? 0 : 1
   end

   def at_new_game?(x,y)
     (450..600).include?(x) && (280..320).include?(y)
   end

   def at_options?(x,y)
     (450..600).include?(x) && (330..370).include?(y)
   end

   def at_exit_game?(x,y)
     (450..600).include?(x) && (380..420).include?(y)
   end

   def start_game
     @song.stop
     Processor.start_game
   end
end