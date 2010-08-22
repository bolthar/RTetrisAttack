
class Block

  attr_accessor :type

  def initialize
    @type = rand(5)
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