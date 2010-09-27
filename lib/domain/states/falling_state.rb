
class FallingState < NormalState

  attr_reader :counter

  def initialize(block)
    super(block)
    @counter = 0
  end

  def tick(playfield)
    @counter += 1
    if @counter == 2
      index = playfield.index(block)
      if index > 5 && !playfield[index - 6].stable?
        playfield[index - 6], playfield[index] = playfield[index], playfield[index - 6]
        #fix this mess
        index = playfield.index(block)
        if index > 5 && !playfield[index - 6].stable?
          block.state = FallingState.new(block)
        else
          block.state = BouncingState.new(block)
        end
      end
    end
  end

  def can_swap?
    return false
  end

  def matches?(other)    
    return false
  end

  def stable?
    return false
  end

end
