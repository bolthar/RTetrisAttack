require 'rubygems'
require 'require_all'

require_all File.join(File.dirname(__FILE__), "domain")
require_all File.join(File.dirname(__FILE__), "engine")

require 'sdl'
include SDL

SDL.init(SDL::INIT_EVERYTHING)
screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)

background = ResourceLoader.load('background')
Surface.blit(background, 0, 0, 0, 0, screen, 0, 0)

black = screen.display_format_alpha
black.fill_rect(0,0,black.w, black.h, [0,0,0,0])
Surface.blit(black, 0, 0, 0, 0, screen, 0, 0)

screen.flip
alpha = 100
while(true)
  Surface.blit(background, 0, 0, 0, 0, screen, 0, 0)
  black.fill_rect(0,0,black.w, black.h, [0,0,0,alpha])
  Surface.blit(black, 0, 0, 0, 0, screen, 0, 0)
  screen.flip
  sleep(0.02)
  alpha -= 10
  
end

