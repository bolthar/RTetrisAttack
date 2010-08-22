
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

  attr_accessor :pos_x, :pos_y

  def initialize
    @pos_x = 0
    @pos_y = 0
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

  def initialize(playfield, screen, cursor, starting_coordinates)
    @start_x = starting_coordinates[0]
    @end_x = starting_coordinates[1]
    @start_y = starting_coordinates[2]
    @end_y = starting_coordinates[3]
    @playfield = playfield
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

  def render
    Surface.blit(area, 0, 0, 0, 0, @screen, @start_x, @start_y)
    (0...@playfield.blocks.length).each do |n|
     (1...@playfield.blocks[n].length).each do |m|
       Surface.blit(tokens[@playfield.blocks[n][m].type],0,0,0,0 ,@screen,@start_x + (n*16), @end_y - (m*16) + 16 - @playfield.ticks)
      end
    end
    Surface.blit(@playfield.cursor.sprite, 0 ,0, 0, 0, @screen, @start_x + (16 * @playfield.cursor.pos_x) - 2, @end_y - (16 * @playfield.cursor.pos_y) - 2 - 16 - @playfield.ticks)
    @screen.update_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y)
  end

end


SDL.init(SDL::INIT_EVERYTHING)
Mixer.open
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

intro = load_music('intro')
theme = load_music('music')

green = load('green')
blue = load('blue')
violet = load('violet')
yellow = load('yellow')
red = load('red')

cursor = Cursor.new

playfield = Playfield.new(cursor)

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

renderer = Renderer.new(playfield, screen, cursor, [start_x, end_x, start_y, end_y])
Thread.new do
  while true
    sleep(0.1)
    playfield.tick
    renderer.render
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
    renderer.render
  end
end








