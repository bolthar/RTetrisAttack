
require 'rubygems'
require 'require_all'

require_all File.join(File.dirname(__FILE__), "domain")
require_all File.join(File.dirname(__FILE__), "engine")

require 'sdl'
include SDL

exit if defined?(Ocra)

SDL.init(SDL::INIT_EVERYTHING)
Mixer.open
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

theme = ResourceLoader.load_music('music')

cursor = Cursor.new

start_x = 88
end_x = 184
start_y = 23
end_y = 215

renderer = Renderer.new(screen, cursor, [start_x, end_x, start_y, end_y])
mixer = SoundPlayer.new

playfield = Playfield.new(cursor)

Thread.new do
  begin
  renderer.startup
  while true
    sleep(0.02)
    playfield.tick
    mixer.play(playfield)
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