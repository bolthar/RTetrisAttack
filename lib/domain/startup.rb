
class Startup

  attr_reader :counter
  
  def initialize(playfield)
    @counter = 0
  end

  def ticks
    return 0
  end

  def time_elapsed
    return 0
  end
  
  def tick(playfield)
    @counter += 1
    if @counter == 200
      playfield.state = Running.new(playfield)
    end
  end

end