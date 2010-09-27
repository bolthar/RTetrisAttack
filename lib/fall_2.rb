#
#require 'rubygems'
#require 'require_all'
#
#require_all File.join(File.dirname(__FILE__), "domain")
#require_all File.join(File.dirname(__FILE__), "engine")
#require File.dirname(__FILE__) + "/col_playfield.rb"
#
#
#require 'sdl'
#include SDL
#
#
#SDL.init(SDL::INIT_EVERYTHING)
#screen = Screen.open(256, 222, 0, HWSURFACE | DOUBLEBUF)
#
#cursor = Cursor.new
#
#start_x = 88
#end_x = 184
#start_y = 23
#end_y = 215
#
#renderer = Renderer.new(screen, cursor, [start_x, end_x, start_y, end_y])
#
#playfield = ColPlayfield.new(cursor)
#
#Thread.new do
#  begin
#  while true
#    sleep(0.2)
#    playfield.tick
#    playfield.check_for_matches
#    renderer.render(playfield)
#  end
#  rescue Exception => ex
#    p "render"
#    p ex
#    p ex.backtrace
#  end
#end
#
#while true
#  event = Event.wait
#  if event.kind_of? Event::KeyDown
#    exit if event.sym == SDL::Key::Q
#    playfield.remove_last if event.sym == SDL::Key::M
#    renderer.render(playfield)
#  end
#end