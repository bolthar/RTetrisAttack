
class ExplodingState < NormalState

  def initialize(block, offset, match_count)
    super(block)
    @offset = offset
    @match_count = match_count
    @counter = 0
  end

  def tick(playfield)
    @counter += 1
    playfield.add_score(1) if exploding?
    if @counter == 100 + @match_count * 8
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

  def is_light?
    return @counter > 80 || (@counter % 4 == 0 || (@counter - 1) % 4 == 0)
  end

  def is_exploded?
    return @counter > 100 + @offset * 8
  end

  def exploding?
    return @counter == 100 + @offset * 8
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
