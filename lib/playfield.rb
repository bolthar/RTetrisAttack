

require File.dirname(__FILE__) + "/stack.rb"

class Playfield < Array

  attr_reader :ticks
  attr_reader :cursor

  def [](column)
    return super(column) || Stack.new
  end

  def initialize(cursor)
    (0...6).each do |n|
      self[n] = Stack.new
      (0...4).each do |m|
        self[n][m] = Block.new
      end
    end
    @ticks = 0
    @cursor = cursor
  end

  def tick
    @ticks += 1
    self.each do |stack|
      stack.fall_blocks
    end
    if @ticks == 16
      self.each do |stack|
        stack.advance        
      end
      @cursor.pos_y += 1
      @ticks = 0
    end
  end

  def swap(x, y)
    Thread.new do
      threads = []
        threads << Thread.new do
          self[x][y].swap(1)
        end
       threads << Thread.new do
         self[x+1][y].swap(-1)
       end
      threads.each { |t| t.join }
      #look out for race conditions
      self[x][y], self[x+1][y] = self[x+1][y], self[x][y]
    end
  end

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


