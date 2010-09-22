
class FloatingState < NormalState

  attr_reader :counter

  def initialize(block)
    super(block)
    @counter = 0
  end

  def tick(playfield)
    @counter += 1
    if @counter == 8
      block.state = FallingState.new(block)
    end
  end

  def matches?(other)
    return false
  end

  def stable?
    return false
  end

end
