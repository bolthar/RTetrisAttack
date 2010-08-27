
class NormalState

  attr_reader :block
  
  def initialize(block)
    @block = block
  end

  def tick(playfield)
    if block.y != 0 && playfield[block.x, block.y - 1].class == NilBlock
      block.state = FallingState.new(block)
    end
  end
  
  def can_swap?
    return true
  end

  def matches?(other)
    return @block.type == other.type
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
      playfield[block.x + @verse, block.y] = block
      block.state = NormalState.new(block)
    end
  end

  def can_swap?
    return false
  end

  def matches?(other)
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
      if playfield[block.x, block.y - 1].class == NilBlock
        playfield[block.x, block.y - 1], playfield[block.x, block.y] = playfield[block.x, block.y], playfield[block.x, block.y - 1]
        block.state = NormalState.new(block)
      end
    end
  end

  def can_swap?
    return false
  end

  def matches?(other)
    return false
  end
  
end

class Block

  attr_accessor :type
  attr_accessor :x, :y

  attr_accessor :state
  attr_accessor :stack

  def self.blocks
    @@blocks ||= []
    return @@blocks
  end

  def initialize
    @type = rand(5)
    @state = NormalState.new(self)
    Block.blocks << self
  end

  def tick(playfield)
    @state.tick(playfield)
  end
  
  def matches?(other)
    return false unless other
    return @state.matches?(other)
  end

  def can_swap?
    return @state.can_swap?
  end

end

class NilBlock < Block

  @@def_instance = nil
  
  def self.value
    unless @@def_instance
      @@def_instance = NilBlock.new
      Block.blocks.delete(@@def_instance)
    end
    return @@def_instance
  end
  
  def initialize
    @state = NormalState.new(self)
    Block.blocks << self
  end
  
  def matches?(other)
    return false
  end

end