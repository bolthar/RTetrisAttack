
class ChainBonus

  attr_reader :counter

  def initialize
    @counter = 0
  end
  
  def tick(block)
    @counter += 1
    if @counter == 60
      block.effects.delete(self)
    end
  end


end