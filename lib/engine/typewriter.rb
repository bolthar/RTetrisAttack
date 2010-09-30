
class Typewriter

  LARGE_CHAR_WIDTH  = 8
  LARGE_CHAR_HEIGHT = 13

  def initialize(time_area, score_area)
    @time_area  = time_area
    @score_area = score_area
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
    time_surface = @time_area.display_format_alpha
    minutes = "%02d" % (ticks.to_i / 60)
    seconds = "%02d" % (ticks - ((ticks.to_i / 60) * 60))
    Surface.blit(@numbers[minutes[0].to_i].red, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 0, 0)
    Surface.blit(@numbers[minutes[1].to_i].red, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 1, 0)
    Surface.blit(time_separator.red           , 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 2, 0)
    Surface.blit(@numbers[seconds[0].to_i].red, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 3, 0)
    Surface.blit(@numbers[seconds[1].to_i].red, 0, 0, 0, 0, time_surface, LARGE_CHAR_WIDTH * 4, 0)
    return time_surface
  end

  def get_score(score)
    score_surface = @score_area.display_format_alpha
    score_string = score.to_s.reverse
    (0..5).each do |position|
      if score_string[position]
        Surface.blit(@numbers[score_string[position].to_i].blue, 0, 0, 0, 0, score_surface,
        LARGE_CHAR_WIDTH * (5 - position), 0)
      end      
    end
    return score_surface
  end

end

