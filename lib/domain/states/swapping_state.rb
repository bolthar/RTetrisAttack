
class SwappingState < NormalState

  attr_reader :counter
  attr_reader :verse

  def initialize(block, verse)
    super(block)
    @verse = verse
    @counter = 0
  end

  def tick(playfield)
    @counter += 1
    if @counter == 4
      index = playfield.index(block)
      playfield[index + @verse], playfield[index] = playfield[index], playfield[index + @verse] if @verse == 1
      block.state = NormalState.new(block)
      playfield[index].state = NormalState.new(playfield[index])
    end
  end

  def can_swap?
    return false
  end

  def matches?(other)
    return false
  end

end
