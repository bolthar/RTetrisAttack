
require 'rubygems'
require 'require_all'

require_all File.join(File.dirname(__FILE__), "domain")
require_all File.join(File.dirname(__FILE__), "engine")

require 'sdl'
include SDL

SDL.init(SDL::INIT_EVERYTHING)
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

typewriter = Typewriter.new

starting_time = Time.now

while(true)
  timespan = Time.now - starting_time
  time_surface = typewriter.get_time(timespan)
  screen.fill_rect(0, 0, screen.w, screen.h, [41,25,23])
  Surface.blit(time_surface, 0, 0, 0, 0, screen, 0, 0)
  screen.flip
  sleep(0.1)
end

