
class Typewriter

  LARGE_CHAR_WIDTH  = 8
  LARGE_CHAR_HEIGHT = 13

  def initialize(screen_area)
    @screen_area = screen_area
    numbers_png = ResourceLoader.load('numbers')
    @format = numbers_png.format
    @numbers = []
    (0..10).each do |number|
      @numbers[number] = Character.new(numbers_png.copy_rect(number * LARGE_CHAR_WIDTH, 0, 8, 13))
    end
  end

  def time_separator
    return @numbers[10]
  end

  def get_time(ticks)
    time_surface = @screen_area.display_format_alpha
    minutes = "%02d" % (ticks.to_i / 60)
    seconds = "%02d" % (ticks - ((ticks.to_i / 60) * 60))
    Surface.blit(@numbers[minutes[0].to_i].blue, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 0, 0)
    Surface.blit(@numbers[minutes[1].to_i].blue, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 1, 0)
    Surface.blit(time_separator.blue           , 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 2, 0)
    Surface.blit(@numbers[seconds[0].to_i].blue, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 3, 0)
    Surface.blit(@numbers[seconds[1].to_i].blue, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 4, 0)
    return time_surface
  end
  

end

