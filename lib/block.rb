
class Block

  def self.blocks
    @@blocks ||= []
    return @@blocks
  end

  def self.delete(block)
    #set neighbours first...
    @@blocks.delete(block)
  end

  attr_reader :type

  attr_reader :left, :right, :up, :down
  
  def initialize
    @type = rand(5)
    Block.blocks << self
  end

  def left=(block)
    @left.right = nil if @left
    @left = block
    block.instance_variable_set(:@right, self)
  end

  def right=(block)
    @right.left = nil if @right
    @right = block
    block.instance_variable_set(:@left, self)
  end

  def up=(block)
    @up.down = nil if @up
    @up = block
    block.instance_variable_set(:@up, self)
  end

  def down=(block)
    @down.up = nil if @down
    @down = block
    block.instance_variable_set(@down, self)
  end

end

class Playfield

  def check_for_matches
    matches = find_matches
    while matches.any?
      matches = find_matches
      matches.each do |match|
        (0...self.length).each do |stack|
          self[stack].delete_if { |block| match.include?(block) }
        end
      end
      matches = find_matches
    end
  end

  def find_matches
    matches = []
    (0...self.length).each do |stack|
      (1...self[stack].length).each do |block|
        horizontal_matches = search_x(stack, block, -1) | search_x(stack, block, 1)
        vertical_matches   = search_y(stack, block, -1) | search_y(stack, block, 1)
        match = []
        match = match | horizontal_matches if horizontal_matches.length > 2
        match = match | vertical_matches if vertical_matches.length > 2
        matches << match if match.any?
      end
    end
    return matches if matches.length < 2
    combined_matches = []
    while combined_matches.length != matches.length
      matches.combination(2).each do |pair|
        merge_matches(pair[0], pair[1]).each do |match|
          combined_matches << match
        end
        matches = combined_matches
      end
    end
    return matches
  end

  def merge_matches(match, other_match)
    return [match | other_match] if match.any? { |block| other_match.include?(block) }
    return [match, other_match]
  end

  def search_x(x, y, verse, results = [])
    results << self[x][y] unless self[x][y].kind_of? OutOfBounds
    return search_x(x + verse, y, verse, results) if self[x+verse][y].matches?(self[x][y])
    return results
  end

  def search_y(x, y, verse, results = [])
    return results if y == 0
    results << self[x][y] unless self[x][y].kind_of? OutOfBounds    
    return search_y(x, y + verse, verse, results) if self[x][y+verse].matches?(self[x][y])
    return results
  end

end

