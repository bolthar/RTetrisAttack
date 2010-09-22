
class NormalState

  attr_reader :block
  attr_writer :ticked

  def initialize(block)
    @block = block
  end

  def check_for_falling(playfield)
    index = playfield.index(block)
    if index > 5 && !playfield[index - 6].stable? && block.class != NilBlock
      block.state = FloatingState.new(block)
    end
  end

  def tick(playfield)
    check_for_falling(playfield)
  end

  def can_swap?
    return true
  end

  def matches?(other)
    return @block.type == other.type
  end

  def stable?
    return true
  end

end
