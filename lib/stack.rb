
class Block

  attr_accessor :type
  attr_accessor :x_offset, :y_offset

  attr_accessor :state

  def initialize
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
    @state = :falling
    4.times do
      @y_offset += 4
      sleep(0.01)
    end
    yield
    @y_offset = 0
    @state = :normal
  end

end

class OutOfBounds < Block

  def matches?(other)
    return false
  end

end

class Stack < Array

  attr_reader :ticks

  def [](row)
    return super(row) || OutOfBounds.new
  end

  def advance
    self.each do |block|
      block.y_offset += 16 if block.state == :falling
    end
    self.insert(0, Block.new)
  end

  def put_on(height)

  end

  def fall_blocks
    self.each do |block|
      begin
      if block && block.state != :falling && self.index(block) != 0 && self[self.index(block) - 1].kind_of?(OutOfBounds)
        Thread.new do
          block.fall do
            index = self.index(block)
            self[index], self[index - 1] = self[index - 1], self[index]
          end
        end
      end
      rescue Exception => ex
        p ex
      end
    end
  end

end