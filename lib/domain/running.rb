
class Running

  attr_reader :ticks
  
  def initialize(playfield)
    @counter = 0
    @ticks = 0
    @time = Time.now
  end

  def time_elapsed
    return Time.now - @time
  end

  def tick(playfield)
    @counter += 1
    if @counter == 16 || playfield.scroll
      @ticks += 1 unless playfield.any? { |b| b.state.class == ExplodingState }
      @counter = 0
    end
    playfield.each do |block|
      block.ticked = false
    end
    playfield.multiplier = 1 unless playfield.active_bonus?
    (0..11).to_a.each do |row|
      (0..5).each do |column|
        playfield[column, row].tick(playfield)
      end
    end
    if @ticks == 16
      (0..11).to_a.reverse.each do |row|
        (0..5).each do |column|
          playfield[column, row + 1] = playfield[column, row]
        end
      end
      (0..5).each do |column|
        playfield[column, 0] = Block.new
      end
      playfield.cursor.pos_y += 1
      @ticks = 0
    end
  end


end