
require 'sdl'
require File.join(File.dirname(__FILE__), 'playfield.rb')

include SDL

def load(filename)
  return Surface.load((File.join(File.dirname(__FILE__), filename + '.png')))
end

def load_music(filename)
  return Mixer::Music.load((File.join(File.dirname(__FILE__), filename + '.ogg')))
end

def load_wave(filename)
  return Mixer::Wave.load((File.join(File.dirname(__FILE__), filename + '.ogg')))
end

class Cursor

  attr_reader :pos_x, :pos_y

  def pos_x=(value)
    if value > -1 && value < 5
      @pos_x = value
    end
  end

  def pos_y=(value)
    if value > 0 && value < 12
      @pos_y = value
    end
  end

  def initialize
    @pos_x = 0
    @pos_y = 1
  end

  def load(filename)
    return Surface.load((File.join(File.dirname(__FILE__), filename + '.png')))
  end

  def sprite
    return @sprite if @sprite
    @sprite = load('cursor')
    return @sprite
  end

end

class Renderer
  def initialize(screen, cursor, starting_coordinates)
    @start_x = starting_coordinates[0]
    @end_x = starting_coordinates[1]
    @start_y = starting_coordinates[2]
    @end_y = starting_coordinates[3]
    @screen = screen
    @cursor = cursor
  end

  def load(filename)
    return Surface.load((File.join(File.dirname(__FILE__), filename + '.png')))
  end

  def area
    return @area if @area
    @area = @screen.copy_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y)
    return @area
  end

  def tokens
    return @tokens if @tokens
    green = load('green')
    blue = load('blue')
    violet = load('violet')
    yellow = load('yellow')
    red = load('red')
    @tokens = {0 => green, 1 => blue, 2 => violet, 3 => yellow, 4 => red}
    return @tokens
  end

  def dark_tokens
    return @dark_tokens if @dark_tokens
    dark_green = darken_surface(tokens[0])
    dark_blue = darken_surface(tokens[1])
    dark_violet = darken_surface(tokens[2])
    dark_yellow = darken_surface(tokens[3])
    dark_red = darken_surface(tokens[4])
    @dark_tokens = {0 => dark_green, 1 => dark_blue, 2 => dark_violet, 3 => dark_yellow, 4 => dark_red}
    return @dark_tokens
  end

  def darken_surface(surface)
    darkened_surface = surface.copy_rect(0,0,surface.w,surface.h)
    (0...darkened_surface.w).each do |x|
      (0...darkened_surface.h).each do |y|
        darkened_surface[x,y] = [darkened_surface.get_rgba(darkened_surface[x,y])[0] * 0.5,
                           darkened_surface.get_rgba(darkened_surface[x,y])[1] * 0.5,
                           darkened_surface.get_rgba(darkened_surface[x,y])[2] * 0.5,
                           darkened_surface.get_rgba(darkened_surface[x,y])[3]]
      end
    end
    return darkened_surface
  end

  def get_tokens(row)
    return dark_tokens if row == 0
    return tokens
  end

  def render(playfield)
    @rendering = true
    Surface.blit(area, 0, 0, 0, 0, @screen, @start_x, @start_y)
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock
        render_normal(block, x, y, playfield.ticks) if block.state.class == NormalState
        render_swapping(block, x, y, playfield.ticks) if block.state.class == SwappingState
        render_falling(block, x, y, playfield.ticks) if block.state.class == FallingState
        end
      end
    end
    Surface.blit(playfield.cursor.sprite, 0 ,0, 0, 0, @screen, @start_x + (16 * playfield.cursor.pos_x) - 2, @end_y - (16 * playfield.cursor.pos_y) - 2 - playfield.ticks)
    @screen.update_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y)
    @rendering = false
  end

  def render_normal(block, x, y, ticks)
    Surface.blit(get_tokens(y)[block.type],0,0,0,0 ,@screen,@start_x + (x*16), @end_y - (y*16) - ticks)
  end

  def render_swapping(block, x, y, ticks)
    Surface.blit(get_tokens(y)[block.type],0,0,0,0 ,@screen,@start_x + (x*16) + ((block.state.verse * block.state.counter) * 2), @end_y - (y*16) - ticks)
  end

  def render_falling(block, x, y, ticks)
    Surface.blit(get_tokens(y)[block.type],0,0,0,0 ,@screen,@start_x + (x*16), @end_y - (y*16) - ticks + (block.state.counter * 8))
  end

end


SDL.init(SDL::INIT_EVERYTHING)
Mixer.open
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

intro = load_music('intro')
theme = load_music('music')

cursor = Cursor.new

background = load('background')

tree  = load('tree')

start_x = 88
end_x = 184
start_y = 23
end_y = 215

Thread.new do
  Mixer.play_music(intro, 0)
  sleep(1.94)
  Mixer.play_music(theme, -1)
end

Surface.blit(background, 0, 0, 0, 0, screen, 0, 0)
Surface.blit(tree, 0, 0, 0, 0, screen, 0, 0)

screen.flip

renderer = Renderer.new(screen, cursor, [start_x, end_x, start_y, end_y])

playfield = Playfield.new(cursor)

Thread.new do
  begin
  while true
    sleep(0.01)
    playfield.tick
    playfield.check_for_matches
    renderer.render(playfield)
  end
  rescue Exception => ex
    p "render"
    p ex
    p ex.backtrace
  end
end

while true  
  event = Event.wait
  if event.kind_of? Event::KeyDown
    exit if event.sym == SDL::Key::Q
    cursor.pos_x += 1 if event.sym == SDL::Key::RIGHT
    cursor.pos_x -= 1 if event.sym == SDL::Key::LEFT
    cursor.pos_y += 1 if event.sym == SDL::Key::UP
    cursor.pos_y -= 1 if event.sym == SDL::Key::DOWN
    playfield.swap(cursor.pos_x, cursor.pos_y) if event.sym == SDL::Key::N
    renderer.render(playfield)
  end
end








