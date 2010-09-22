
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
    if @counter == 8
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
          block.state = NormalState.new(block)
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

class Block

  attr_accessor :type

  attr_accessor :state
  attr_accessor :stack

  attr_accessor :ticked

  def initialize
    @type = rand(5)
    @state = NormalState.new(self)
  end

  def tick(playfield)
    unless @ticked
      @state.tick(playfield)
      @ticked = true
    end
  end

  def matches?(other)
    return false unless other
    return @state.matches?(other)
  end

  def can_swap?
    return @state.can_swap?
  end

  def stable?
    return @state.stable?
  end

end

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

  def execute_tick
    
  end

end