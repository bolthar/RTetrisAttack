
class NilBlock < Block

  def initialize
    @state = NormalState.new(self)
  end

  def matches?(other)
    return false
  end

  def stable?
    return false
  end

  def tick(playfield)
    @ticked = true
  end

end