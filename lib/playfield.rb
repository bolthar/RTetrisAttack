

require File.dirname(__FILE__) + "/stack.rb"

class SwapCache

  attr_reader :ticks

  def blocks
    return [@block_data_one[0], @block_data_two[0]]
  end

  def initialize(block_data_one, block_data_two, ask_for_render)
    @block_data_one = block_data_one
    @block_data_two = block_data_two
    @ticks = 4
    Thread.new do
      while @ticks != 0
        sleep(0.02)
        @ticks -= 1
        ask_for_render.call(self)
      end
      yield(@block_data_one, @block_data_two)
    end
  end

  def y
    return @block_data_one[2]
  end

  def x
    return @block_data_one[1]
  end

end

class Playfield

  attr_reader :blocks
  attr_reader :ticks
  attr_reader :cursor
  attr_reader :swapcaches
  
  def initialize(cursor, renderer)
    @blocks = []
    (0...6).each do |n|
      @blocks[n] = Stack.new
      (0...4).each do |m|
        @blocks[n][m] = Block.new
      end
    end
    @ticks = 0
    @cursor = cursor
    @swapcaches = []
    @renderer = renderer
  end

  def tick
    @ticks += 1
    if @ticks == 16
      @blocks.each { |block| block.advance }
      @cursor.pos_y += 1
      @ticks = 0
    end
    @renderer.render(self)
  end

  def in_cache?(block)
    @swapcaches.each do |cache|
      return true if cache.blocks.include?(block)
    end
    return false
  end

  def ask_for_render(swapcache)
    block_one = swapcache.blocks[0]
    block_two = swapcache.blocks[1]
    @renderer.render_swap(block_one, block_two, swapcache.x, swapcache.y, @ticks, swapcache.ticks)
  end
  
  def swap(x, y)
    if @blocks[x][y] && @blocks[x+1][y]
      cache = SwapCache.new([@blocks[x][y],x,y],[@blocks[x+1][y],x+1,y], method(:ask_for_render)) do |bd1, bd2|
        @blocks[x][y] = bd2[0]
        @blocks[x+1][y] = bd1[0]
        check_for_matches
        @swapcaches.delete(cache)
      end
      @swapcaches << cache
    else
      if @blocks[x][y]
        @blocks[x+1].push(@blocks[x][y])
        @blocks[x].delete(@blocks[x][y])
      elsif @blocks[x+1][y]
        @blocks[x].push(@blocks[x+1][y])
        @blocks[x+1].delete(@blocks[x+1][y])
      end
    end
  end

  def check_for_matches
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
      (1...@blocks[stack].length).each do |block|
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
    return results if x + verse >= @blocks.length || !@blocks[x+verse][y]
    results << @blocks[x][y]
    return search_x(x + verse, y, verse, results) if @blocks[x+verse][y].type == @blocks[x][y].type
    return results
  end

  def search_y(x, y, verse, results = [])
    return results if x >= @blocks.length || !@blocks[x][y+verse] || y == 0
    results << @blocks[x][y]
    return search_y(x, y + verse, verse, results) if @blocks[x][y+verse].type == @blocks[x][y].type
    return results
  end

end


