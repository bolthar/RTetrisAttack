
class Cursor

  attr_reader :pos_x, :pos_y

  def pos_x=(value)
    if value > -1 && value < 5
      @pos_x = value
    end
  end

  def pos_y=(value)
    if value > 0 && value < 12
      @pos_y = value
    end
  end

  def initialize
    @pos_x = 0
    @pos_y = 1
  end

  #move somewhere into engine 
  def sprite
    return @sprite if @sprite
    @sprite = ResourceLoader.load('cursor')
    return @sprite
  end

end