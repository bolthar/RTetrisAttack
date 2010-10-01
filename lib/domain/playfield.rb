

class Playfield < Array

  attr_reader :cursor

  attr_accessor :scroll
  attr_accessor :multiplier

  attr_reader :score

  attr_accessor :state


  def add_score(value)
    @score += value * @multiplier
  end

  def time_elapsed
    return @state.time_elapsed
  end

  def ticks
    return @state.ticks
  end
  
  def [](*args)
    if args.length == 2
      return NilBlock.new if args[0] < 0
      return NilBlock.new if args[1] < 0
      return NilBlock.new if args[0] > 5
      return super(args[0] + (args[1]*6)) || NilBlock.new
    else
      super(*args)
    end
  end

  def []=(*args)
    if args.length == 3
      super(args[0] + (args[1]*6), args[2])
    else      
      super(args[0], args[1])
    end
  end

  def initialize(cursor)
    @state = Startup.new(self)
    (0..5).each do |column|
      (0..3).each do |row|
        self[column, row] = get_non_matching_block(column, row)
      end
      (4..11).each do |row|
        self[column, row] = NilBlock.new
      end
    end    
    @counter = 0
    @cursor = cursor
    @multiplier = 1
    @time = Time.now
    @score = 0
  end

  def get_non_matching_block(column, row)
    while true
      block = Block.new
      unless block.matches?(self[column + 1, row]) ||
         block.matches?(self[column - 1, row]) ||
         block.matches?(self[column, row + 1]) ||
         block.matches?(self[column, row - 1])
        return block
      end
    end
  end

  def tick
    @state.tick(self)
  end

  def swap(x, y)
    block_left  = self[x,y]
    block_right = self[x+1, y]
    if block_left.can_swap? && block_right.can_swap?
      block_left.state = SwappingState.new(block_left, 1)
      block_right.state = SwappingState.new(block_right, -1)
    end    
  end

  def active_bonus?
    return self.any? { |b| b.bonus }
  end

  def get_effect_block(match)
    return match
    .sort { |a,b| self.index(a) % 6 <=> self.index(b) % 6 }
    .sort { |a,b| self.index(b) / 6 <=> self.index(a) / 6 }.first
  end

  def check_for_matches
    match = find_matches
    effect_block = get_effect_block(match)
    if match.count > 3
      effect_block.effects << LengthBonus.new(match.count)
      add_score(match.count)
    end
    if match.any? { |b| b.bonus }
      @multiplier += 1
      effect_block.effects << ChainBonus.new(@multiplier)
    end
   
    offsets = (0...match.length).to_a.sort_by { rand }
    match.each do |block|        
      index = self.index(block)
      if index != nil         
        self[index].state = ExplodingState.new(self[index], offsets.shift, match.length)
      end
    end
  end

  def find_matches
    matches = []
    (0..5).each do |x|
      (1..11).each do |y|
        horizontal_matches = search_x(x, y, -1) | search_x(x, y, 1)
        vertical_matches   = search_y(x, y, -1) | search_y(x, y, 1)
        match = []
        match = match | horizontal_matches if horizontal_matches.length > 2
        match = match | vertical_matches if vertical_matches.length > 2
        matches << match if match.any?
      end      
    end
    return matches.flatten.uniq
  end

  def merge_matches(match, other_match)
    return [match | other_match] if match.any? { |block| other_match.include?(block) }
    return [match, other_match]
  end

  def search_x(x, y, verse, results = [])
    return results unless self[x,y]
    results << self[x,y]
    return search_x(x + verse, y, verse, results) if self[x,y].matches?(self[x + verse,y]) && self[x + verse, y].matches?(self[x,y])
    return results
  end

  def search_y(x, y, verse, results = [])
    return results if y == 0 || !self[x,y]
    results << self[x,y] 
    return search_y(x, y + verse, verse, results) if self[x,y].matches?(self[x,y + verse]) && self[x, y + verse].matches?(self[x,y])
    return results
  end

end