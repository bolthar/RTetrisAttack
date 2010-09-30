
class BouncingState < NormalState

  attr_reader :counter

  def initialize(block)
    super(block)
    @counter = 0
  end

  def animation_frame
    return @counter / 4
  end

  def tick(playfield)
    @counter += 1
    if @counter == 12
      block.state = NormalState.new(block)
      block.bonus = false
    end
  end
  
end