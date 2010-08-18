

class Block

  attr_reader :type

  def initialize
    @type = rand(5)
  end

end

class Playfield

  attr_reader :blocks
  
  def initialize
    @blocks = []
    (0...6).each do |n|
      @blocks[n] = []
      (0...12).each do |m|
        @blocks[n][m] = Block.new
      end
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
    matches = find_triplets
    while matches
      (0...@blocks.length).each do |stack|
        (0...@blocks[stack].length).each do |block|
          @blocks[stack].delete_if { |b| matches.include?(b) }
        end
      end      
      matches = find_triplets
    end
  end

  def find_triplets
    (0...@blocks.length).each do |stack|
      (0...@blocks[stack].length).each do |block|
        horizontal_matches = search_x(stack, block, -1) | search_x(stack, block, 1)
        vertical_matches   = search_y(stack, block, -1) | search_y(stack, block, 1)
        match = []
        match = match + horizontal_matches if horizontal_matches.length > 2
        match = match + vertical_matches if vertical_matches.length > 2
        return match if match.any?
      end
    end
    return nil
  end

  def search_x(x, y, verse, results = nil)
    results ||= []
    return results if x + verse >= @blocks.length || !@blocks[x+verse][y]
    return search_x(x + verse, y, verse, results) if @blocks[x+verse][y].type == @blocks[x][y].type
    return results
  end

  def search_y(x, y, verse, results = nil)
    results ||= []
    return results if y + verse >= @blocks.length || !@blocks[x][y+verse]
    results << @blocks[x][y]
    return search_y(x, y + verse, verse, results) if @blocks[x][y+verse].type == @blocks[x][y].type
    return results
  end

end