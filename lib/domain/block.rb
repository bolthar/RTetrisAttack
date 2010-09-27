
class Block

  attr_accessor :type

  attr_accessor :state
  attr_accessor :stack

  attr_accessor :bonus

  attr_accessor :ticked

  attr_reader :effects

  def initialize
    @effects = []
    @type = rand(5)
    @state = NormalState.new(self)    
  end

  def tick(playfield)
    unless @ticked
      @state.tick(playfield)
      @effects.each do |effect|
        effect.tick(self)
      end
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
