
class Block

  attr_accessor :type
  attr_reader :x_offset

  def initialize
    @type = rand(5)
    @x_offset = 0
  end

  def swap(verse)
    5.times do
      @x_offset += (4 * verse)
      sleep(0.02)
    end
    @x_offset = 0
  end

end

class Stack < Array

  attr_reader :ticks
  
  def advance
    self.insert(0, Block.new)
  end

  def put_on(height)

  end

end