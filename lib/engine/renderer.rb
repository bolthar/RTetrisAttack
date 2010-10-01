
class Renderer
  
  def initialize(screen, cursor, starting_coordinates)
    @start_x = starting_coordinates[0]
    @end_x = starting_coordinates[1]
    @start_y = starting_coordinates[2]
    @end_y = starting_coordinates[3]
    @screen = screen
    @cursor = cursor
    @bounce_animation = {}
    #Temp...
    @start_op = 0   
  end

  def startup
    @background = ResourceLoader.load('background')
    @tree = ResourceLoader.load('tree')
#    Surface.blit(@background, 0, 0, 0, 0, @screen, 0, 0)
#    Surface.blit(@tree, 0, 0, 0, 0, @screen, 0, 0)
    @screen.flip
  end

  def area
    return @area if @area
    @area = @screen.copy_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y)
    return @area
  end

  def tokens
    return @tokens if @tokens
    green = ResourceLoader.load('/blocks/0')
    blue = ResourceLoader.load('/blocks/1')
    violet = ResourceLoader.load('/blocks/2')
    yellow = ResourceLoader.load('/blocks/3')
    red = ResourceLoader.load('/blocks/4')
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
    dark_green = lighten_surface(tokens[0], 0.5)
    dark_blue = lighten_surface(tokens[1], 0.5)
    dark_violet = lighten_surface(tokens[2], 0.5)
    dark_yellow = lighten_surface(tokens[3], 0.5)
    dark_red = lighten_surface(tokens[4], 0.5)
    @light_tokens = {0 => dark_green, 1 => dark_blue, 2 => dark_violet, 3 => dark_yellow, 4 => dark_red}
    return @light_tokens
  end

  def darken_surface(surface)
    return alter_surface_color(surface, 0.5)
  end

  def lighten_surface(surface, factor)
    altered_surface = surface.copy_rect(0,0,surface.w,surface.h)
    (0...altered_surface.w).each do |x|
      (0...altered_surface.h).each do |y|
        altered_surface[x,y] = [altered_surface.get_rgba(altered_surface[x,y])[0] + ((255 - altered_surface.get_rgba(altered_surface[x,y])[0]) * factor),
                           altered_surface.get_rgba(altered_surface[x,y])[1] + ((255 - altered_surface.get_rgba(altered_surface[x,y])[1]) * factor),
                           altered_surface.get_rgba(altered_surface[x,y])[2] + ((255 - altered_surface.get_rgba(altered_surface[x,y])[2]) * factor),
                           altered_surface.get_rgba(altered_surface[x,y])[3]]
      end
    end
    return altered_surface
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

  def bounce_animation(type)
    return @bounce_animation[type] if @bounce_animation[type]   
    bounce = ResourceLoader.load("/blocks/#{type}bounce")
    bb1 = bounce.copy_rect(0, 0, 16, 16)
    bb2 = bounce.copy_rect(16, 0, 16, 16)
    bb3 = bounce.copy_rect(32, 0, 16, 16)
    @bounce_animation[type] = [bb1, bb2, bb3]
    return @bounce_animation[type]
  end

  def get_tokens(row)
    return dark_tokens if row == 0
    return tokens
  end

  def combo
    return @combo if @combo
    @combo = []
    (4..12).each do |length|
      @combo[length] = ResourceLoader.load("/bonus/#{length}")
    end
    return @combo
  end

  def chain
    return @chain if @chain
    @chain = []
    (2..5).each do |length|
      @chain[length] = ResourceLoader.load("/bonus/x#{length}")
    end
    return @chain
  end

  def get_effect(effect)
    return combo[effect.length] if effect.class == LengthBonus
    return chain[effect.multiplier] if effect.class == ChainBonus
  end

  def render(playfield)
    score_x = 190
    score_y = 57
    if playfield.state.class == Startup
      Surface.blit(@background, 0, 0, 0, 0, @screen, 0, 0)
      Surface.blit(@tree, 0, 0, 0, 0, @screen, 0, 0)
    end
    @typewriter ||= Typewriter.new(@screen.copy_rect(33, 33, 40, 13), @screen.copy_rect(score_x, score_y, 48, 13))
    Surface.blit(area, 0, 0, 0, 0, @screen, @start_x, @start_y)
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock || (y == 0 && playfield.state.class == Startup)
        render_normal(block, x, y, playfield.ticks) if block.state.class == NormalState || block.state.class == FloatingState
        render_exploding(block, x, y, playfield.ticks) if block.state.class == ExplodingState
        render_bouncing(block, x, y, playfield.ticks) if block.state.class == BouncingState
        render_swapping(block, x, y, playfield.ticks) if block.state.class == SwappingState
        render_falling(block, x, y, playfield.ticks) if block.state.class == FallingState        
        end
      end
    end
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock
          render_effects(block.effects, x, y)
        end
      end
    end
    Surface.blit(playfield.cursor.sprite, 0 ,0, 0, 0, @screen, @start_x + (16 * playfield.cursor.pos_x) - 2, @end_y - (16 * playfield.cursor.pos_y) - 2 - playfield.ticks)
    Surface.blit(@typewriter.get_time(playfield.time_elapsed), 0, 0, 0, 0, @screen, 33, 33)    
    @screen.update_rect(33, 33, 40, 13) if playfield.state.class == Running || !@updated
    Surface.blit(@typewriter.get_score(playfield.score), 0, 0, 0, 0, @screen, score_x, score_y)
    @screen.update_rect(score_x, score_y, 48, 13) if playfield.state.class == Running || !@updated
    @screen.update_rect(@start_x, @start_y, @end_x - @start_x, @end_y - @start_y) if playfield.state.class == Running || !@updated
    if playfield.state.class == Startup
      @updated = true
      darken(playfield.state.counter * 10 < 255 ? 255 - playfield.state.counter * 10 : 0)
    end   
  end

  def darken(alpha)    
    black = @screen.display_format_alpha
    black.fill_rect(0,0,black.w, black.h, [0,0,0,alpha])
    Surface.blit(black, 0, 0, 0, 0, @screen, 0, 0)
    @screen.flip
  end



  def render_block(surface, x, y)
    Surface.blit(surface, 0, 0, 0, 0, @screen, x, y)
  end

  def render_normal(block, x, y, ticks)
    render_block(get_tokens(y)[block.type],
                 @start_x + (x*16),
                 @end_y - (y*16) - ticks)
  end

  def render_exploding(block, x, y, ticks)
    return if block.state.is_exploded?
    if block.state.is_light?
      surface = light_tokens[block.type]
    else
      surface = get_tokens(y)[block.type]
    end
    render_block(surface,
                 @start_x + (x*16),
                 @end_y - (y*16) - ticks)
  end

  def render_swapping(block, x, y, ticks)
    Surface.blit(get_tokens(y)[block.type],0,0,0,0 ,@screen,@start_x + (x*16) + ((block.state.verse * block.state.counter) * 4), @end_y - (y*16) - ticks)
  end

  def render_falling(block, x, y, ticks)
    Surface.blit(get_tokens(y)[block.type],0,0,0,0 ,@screen,@start_x + (x*16), @end_y - (y*16) - ticks + (block.state.counter * 8))
  end

  def render_bouncing(block, x, y, ticks)
    Surface.blit(bounce_animation(block.type)[block.state.animation_frame],0,0,0,0, @screen,@start_x + (x*16), @end_y - (y*16) - ticks)
  end

  def render_effects(effects, x, y)
    offset = 0
    effects.each do |effect|
      surface = get_effect(effect)
      Surface.blit(surface, 0, 0, 0, 0, @screen, @start_x + (x*16), @end_y - (y*16) - 10 - offset + (2*(8 - (Math.sqrt(effect.counter)))))
      offset += 20
    end
  end

end