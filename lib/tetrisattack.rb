
require 'rubygems'
require 'require_all'

require_all File.join(File.dirname(__FILE__), "domain")
require_all File.join(File.dirname(__FILE__), "engine")

require 'sdl'
include SDL


SDL.init(SDL::INIT_EVERYTHING)
Mixer.open
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

intro = ResourceLoader.load_music('intro')
theme = ResourceLoader.load_music('music')

cursor = Cursor.new

background = ResourceLoader.load('background')
tree = ResourceLoader.load('tree')

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
    sleep(0.02)
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