
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
      x_pos = index % 6
      y_pos = index / 6
      while(!playfield[x_pos, y_pos + 1].kind_of?(NilBlock))
        playfield[x_pos, y_pos + 1].bonus = true
        y_pos += 1
      end
    end
  end

  def matches?(other)
    return false
  end

  def stable?
    return true
  end

  def can_swap?
    return false
  end

end
