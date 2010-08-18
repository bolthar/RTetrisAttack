
require 'sdl'

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

def swap(blocks, pos_x, pos_y)
  blocks[pos_x][pos_y], blocks[pos_x + 1][pos_y] = blocks[pos_x + 1][pos_y], blocks[pos_x][pos_y]
end

SDL.init(SDL::INIT_EVERYTHING)
Mixer.open
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF | FULLSCREEN)

intro = load_music('intro')
theme = load_music('music')

green = load('green')
blue = load('blue')
violet = load('violet')
yellow = load('yellow')
red = load('red')

cursor = load('cursor')

tokens = [green, blue, violet, yellow, red]

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

area = screen.copy_rect(start_x, start_y, end_x - start_x, end_y - start_y)
screen.flip

blocks = []
(0...6).each do |n|
  blocks[n] = []
  (0...12).each do |m|
    blocks[n][m] = tokens[rand(tokens.length)]
  end
end

pos_x = 0
pos_y = 0

while true
  event = Event.wait
  if event.kind_of? Event::KeyDown
    exit if event.sym == SDL::Key::Q
    pos_x += 1 if event.sym == SDL::Key::RIGHT
    pos_x -= 1 if event.sym == SDL::Key::LEFT
    pos_y -= 1 if event.sym == SDL::Key::UP
    pos_y += 1 if event.sym == SDL::Key::DOWN
    swap(blocks, pos_x, pos_y) if event.sym == SDL::Key::N
    Surface.blit(area, 0, 0, 0, 0, screen, start_x, start_y)
    (0...blocks.length).each do |n|
       (0...blocks[n].length).each do |m|
         Surface.blit(blocks[n][m],0,0,0,0,screen,start_x + (n*16), start_y+ (m*16))
       end
    end
    Surface.blit(cursor, 0 ,0, 0, 0, screen,start_x + (16 * pos_x) - 2, start_y + (16 * pos_y) - 2)
  screen.update_rect(start_x, start_y, end_x - start_x, end_y - start_y)
  end
  
end



