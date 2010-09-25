
class ColPlayfield < Playfield

  def initialize(cursor)
    (0..5).each do |column|
      (0..9).each do |row|
        if column == 0
          self[column, row] = get_non_matching_block(column, row)
        else
          self[column, row] = NilBlock.new
        end

      end
      (10..11).each do |row|
        self[column, row] = NilBlock.new
      end
    end
    @ticks = 0
    @counter = 0
    @cursor = cursor
  end

  def tick
    @counter += 1
    if @counter == 8
      @ticks += 1
      @counter = 0
    end
    self.each do |block|
      block.ticked = false if block
    end
    (0..11).to_a.each do |row|
      (0..5).each do |column|
        self[column, row].tick(self)
      end
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

  def remove_last
    self[0, 3] = NilBlock.new
    self[0, 4] = NilBlock.new
    self[0, 5] = NilBlock.new
  end

end
