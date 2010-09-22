
class ExplodingState < NormalState

  def initialize(block)
    super(block)
    @counter = 60
  end

  def tick(playfield)
    @counter -= 1
    if @counter == 0
      index = playfield.index(block)
      playfield[index] = NilBlock.new
    end
  end

  def matches?(other)
    return false
  end

  def stable?
    return true
  end

end
