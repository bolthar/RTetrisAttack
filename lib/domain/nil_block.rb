
class NilBlock < Block

  def initialize
    @state = NormalState.new(self)
    @effects = []
  end

  def matches?(other)
    return false
  end

  def stable?
    return false
  end

  def execute_tick
  end

end