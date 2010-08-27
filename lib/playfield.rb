

require File.dirname(__FILE__) + "/stack.rb"

class Playfield < Array

  attr_reader :ticks
  attr_reader :cursor

  def [](column, row)
    return NilBlock.value if column < 0
    return NilBlock.value if row < 0
    return super(column + (row*6)) || NilBlock.value
  end

  def []=(column, row, block)    
    block.x = column
    block.y = row
    super(column + (row*6), block)
  end

  def initialize(cursor)
    (0..5).each do |column|
      (0..3).each do |row|
        self[column, row] = get_non_matching_block(column, row)
      end
      (4..11).each do |row|
        self[column, row] = NilBlock.new
      end
    end    
    @ticks = 0
    @counter = 0
    @cursor = cursor
  end

  def get_non_matching_block(column, row)
    while true
      block = Block.new
      if block.matches?(self[column + 1, row]) ||
         block.matches?(self[column - 1, row]) ||
         block.matches?(self[column, row + 1]) ||
         block.matches?(self[column, row - 1])
         Block.blocks.delete(block)
      else
        return block
      end
    end
  end

  def tick
    @counter += 1
    if @counter == 8
      @ticks += 1
      @counter = 0
    end
    Block.blocks.each do |block|
      block.tick(self)
    end
    if @ticks == 16
      (0..11).to_a.reverse.each do |row|
        (0..5).each do |column|
          self[column, row + 1] = self[column, row]
        end
      end
      (0..5).each do |column|
        self[column, 0] = Block.new
      end
      @cursor.pos_y += 1
      @ticks = 0
    end
  end

  def swap(x, y)
    block_left  = self[x,y]
    block_right = self[x+1, y]
    if block_left.can_swap?
      block_left.state = SwappingState.new(block_left, 1)
    end
    if block_right.can_swap?
      block_right.state = SwappingState.new(block_right, -1)
    end    
  end

  def check_for_matches
    matches = find_matches
    matches.each do |match|
      match.each do |block|
        self[block.x, block.y] = NilBlock.new
        Block.blocks.delete(block)
      end
    end
  end

  def find_matches
    matches = []
    self.each do |block|
      if block
        horizontal_matches = search_x(block.x, block.y, -1) | search_x(block.x, block.y, 1)
        vertical_matches   = search_y(block.x, block.y, -1) | search_y(block.x, block.y, 1)
        match = []
        match = match | horizontal_matches if horizontal_matches.length > 2
        match = match | vertical_matches if vertical_matches.length > 2
        matches << match if match.any?
      end
    end
    return matches
  end

  def merge_matches(match, other_match)
    return [match | other_match] if match.any? { |block| other_match.include?(block) }
    return [match, other_match]
  end

  def search_x(x, y, verse, results = [])
    return results unless self[x,y]
    results << self[x,y]
    return search_x(x + verse, y, verse, results) if self[x,y].matches?(self[x + verse,y])
    return results
  end

  def search_y(x, y, verse, results = [])
    return results if y == 0 || !self[x,y]
    results << self[x,y] 
    return search_y(x, y + verse, verse, results) if self[x,y].matches?(self[x,y + verse])
    return results
  end

end


