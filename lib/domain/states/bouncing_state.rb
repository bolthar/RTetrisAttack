
class BouncingState < NormalState

  def initialize(block)
    super(block)
    @counter = 0
  end

  def animation_frame
    return @counter / 2
  end

  def tick(playfield)
    @counter += 1
    if @counter == 6
      block.state = NormalState.new(block)
    end
    super(playfield)
  end
  
end