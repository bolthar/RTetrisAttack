
class LengthBonus

  attr_reader :length
  attr_reader :counter

  def initialize(length)
    @length = length
    @counter = 0
  end

  def tick(block)
    @counter += 1
    if @counter == 120
      block.effects.delete(self)
    end
  end
  
end