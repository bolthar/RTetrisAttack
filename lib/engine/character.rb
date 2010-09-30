
class Character

  OUTER_COLOR = [255,0,0,255]
  INNER_COLOR = [0,255,0,255]

  def initialize(sprite)
    @sprite = sprite
  end

  def apply_color(outer, inner)
    target_sprite = @sprite.display_format_alpha
    (0...target_sprite.w).each do |x|
      (0...target_sprite.h).each do |y|
        pixel = target_sprite.get_rgba(target_sprite[x,y])
        target_sprite[x,y] = outer if pixel == OUTER_COLOR
        target_sprite[x,y] = inner if pixel == INNER_COLOR
      end
    end
    return target_sprite
  end

  def blue
    @blue = apply_color([0, 32, 104, 255], [112, 248, 248, 255]) unless @blue
    return @blue
  end

end