
class Block

  attr_accessor :type
  attr_accessor :x_offset, :y_offset

  attr_accessor :state
  attr_accessor :stack

  def initialize(stack)
    @stack = stack
    @type = rand(5)
    @x_offset = 0
    @y_offset = 0
    @state = :normal
  end

  def matches?(other)
    return false if @state == :firstrow || @state == :falling || @state == :swapping
    return other.type == @type
  end

  def swap(verse)
    @state = :swapping
    4.times do
      @x_offset += (4 * verse)
      sleep(0.02)
    end
    @x_offset = 0
    @state = :normal
  end

  def fall
    begin
    @state = :falling
    while @stack[@stack.index(self) - 1].kind_of?(OutOfBounds)
      while @y_offset < 16
        @y_offset += 2
        sleep(0.2)
      end
      current_index = @stack.index(self)
      @stack[current_index - 1] = @stack[current_index]
    end
    @y_offset = 0
    @state = :normal
    rescue Exception => ex
      p ex
      p ex.backtrace
    end
  end

end

class OutOfBounds < Block

  def matches?(other)
    return false
  end

  def fall
    
  end
  
end

class Stack < Array

  attr_reader :playfield

  def initialize(playfield)
    @playfield = playfield
  end
  
  def [](row)
    return super(row) || OutOfBounds.new(self)
  end

  def []=(row, block)
    super(row, block)
    block.stack = self
  end

  def advance
    self.each do |block|
      block.y_offset += 16 if block && block.state == :falling
    end
    self.insert(0, Block.new(self))
  end

  def fall_blocks
    self.each do |block|
      if !block.kind_of?(OutOfBounds) && self.index(block) != 0 && self[self.index(block) - 1].kind_of?(OutOfBounds)
        Thread.new do
          block.fall
        end
      end
    end
  end

end