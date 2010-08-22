

require File.dirname(__FILE__) + "/stack.rb"

class Playfield

  attr_reader :blocks
  attr_reader :ticks
  attr_reader :cursor
  
  def initialize(cursor)
    @blocks = []
    (0...6).each do |n|
      @blocks[n] = Stack.new
      (0...4).each do |m|
        @blocks[n][m] = Block.new
      end
    end
    @ticks = 0
    @cursor = cursor
  end

  def tick
    @ticks += 1
    if @ticks == 16
      @blocks.each { |block| block.advance }
      @cursor.pos_y += 1
      @ticks = 0
    end
  end

  def swap(x, y)
    if @blocks[x][y] && @blocks[x+1][y]
      @blocks[x][y], @blocks[x+1][y] = @blocks[x+1][y], @blocks[x][y]
    else
      if @blocks[x][y]
        @blocks[x+1].push(@blocks[x][y])
        @blocks[x].delete(@blocks[x][y])
      elsif @blocks[x+1][y]
        @blocks[x].push(@blocks[x+1][y])
        @blocks[x+1].delete(@blocks[x+1][y])
      end
    end
    matches = find_matches
    while matches.any?
      matches = find_matches
      matches.each do |match|
        (0...@blocks.length).each do |stack|
          @blocks[stack].delete_if { |block| match.include?(block) }
        end
      end
      matches = find_matches
    end
  end

  def find_matches
    matches = []
    (0...@blocks.length).each do |stack|
      (0...@blocks[stack].length).each do |block|
        horizontal_matches = search_x(stack, block, -1) + search_x(stack, block, 1)
        vertical_matches   = search_y(stack, block, -1) + search_y(stack, block, 1)
        match = []
        match = match + horizontal_matches.uniq if horizontal_matches.uniq.length > 2
        match = match + vertical_matches.uniq if vertical_matches.uniq.length > 2
        matches << match.uniq if match.any?
      end
    end    
  end

  def search_x(x, y, verse, results = [])
    return results if x + verse >= @blocks.length || !@blocks[x+verse][y]
    results << @blocks[x][y]
    return search_x(x + verse, y, verse, results) if @blocks[x+verse][y].type == @blocks[x][y].type
    return results
  end

  def search_y(x, y, verse, results = [])
    return results if x >= @blocks.length || !@blocks[x][y+verse]
    results << @blocks[x][y]
    return search_y(x, y + verse, verse, results) if @blocks[x][y+verse].type == @blocks[x][y].type
    return results
  end

end
#
#counter = 0
#play = Playfield.new(nil)
#play.blocks.each do |arr|
#  arr.each do |block|
#    block.type = counter
#    counter += 1
#  end
#end
#play.blocks[3][5].type = 1000
#play.blocks[3][6].type = 1000
#play.blocks[3][7].type = 1000
#play.blocks[3][8].type = 1000
#play.blocks[2][5].type = 1000
#play.blocks[1][5].type = 1000
#p play.find_matches

