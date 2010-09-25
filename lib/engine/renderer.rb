
class Renderer
  
  def initialize(screen, cursor, starting_coordinates)
    @start_x = starting_coordinates[0]
    @end_x = starting_coordinates[1]
    @start_y = starting_coordinates[2]
    @end_y = starting_coordinates[3]
    @screen = screen
    @cursor = cursor
  end

  def area
    return @area if @area
    @area = @screen.copy_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y)
    return @area
  end

  def tokens
    return @tokens if @tokens
    green = ResourceLoader.load('green')
    blue = ResourceLoader.load('blue')
    violet = ResourceLoader.load('violet')
    yellow = ResourceLoader.load('yellow')
    red = ResourceLoader.load('red')
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

  def light_tokens
    return @light_tokens if @light_tokens
    dark_green = lighten_surface(tokens[0])
    dark_blue = lighten_surface(tokens[1])
    dark_violet = lighten_surface(tokens[2])
    dark_yellow = lighten_surface(tokens[3])
    dark_red = lighten_surface(tokens[4])
    @light_tokens = {0 => dark_green, 1 => dark_blue, 2 => dark_violet, 3 => dark_yellow, 4 => dark_red}
    return @light_tokens
  end

  def darken_surface(surface)
    return alter_surface_color(surface, 0.5)
  end

  def lighten_surface(surface)
    return alter_surface_color(surface, 1.5)
  end

  def alter_surface_color(surface, factor)
    altered_surface = surface.copy_rect(0,0,surface.w,surface.h)
    (0...altered_surface.w).each do |x|
      (0...altered_surface.h).each do |y|
        altered_surface[x,y] = [altered_surface.get_rgba(altered_surface[x,y])[0] * factor,
                           altered_surface.get_rgba(altered_surface[x,y])[1] * factor,
                           altered_surface.get_rgba(altered_surface[x,y])[2] * factor,
                           altered_surface.get_rgba(altered_surface[x,y])[3]]
      end
    end
    return altered_surface
  end

  def get_tokens(row, state)
    return dark_tokens if row == 0
    return light_tokens if state.class == ExplodingState
    return tokens
  end

  def render(playfield)
    @rendering = true
    Surface.blit(area, 0, 0, 0, 0, @screen, @start_x, @start_y)
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock
        render_normal(block, x, y, playfield.ticks) if block.state.class == NormalState || block.state.class == FloatingState || block.state.class == ExplodingState
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
    Surface.blit(get_tokens(y, block.state)[block.type],0,0,0,0 ,@screen,@start_x + (x*16), @end_y - (y*16) - ticks)
  end

  def render_swapping(block, x, y, ticks)
    Surface.blit(get_tokens(y, block.state)[block.type],0,0,0,0 ,@screen,@start_x + (x*16) + ((block.state.verse * block.state.counter) * 4), @end_y - (y*16) - ticks)
  end

  def render_falling(block, x, y, ticks)
    Surface.blit(get_tokens(y, block.state)[block.type],0,0,0,0 ,@screen,@start_x + (x*16), @end_y - (y*16) - ticks + (block.state.counter * 8))
  end

end