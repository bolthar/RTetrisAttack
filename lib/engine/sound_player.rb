
class SoundPlayer

  def initialize
    @pop    = ResourceLoader.load_wave('pop')
    @swap   = ResourceLoader.load_wave('swap')
    @bounce = ResourceLoader.load_wave('bounce')
    @bonus  = ResourceLoader.load_wave('bonus')
    @channels = [true, true, true]
  end

  def play_music(music)
    Mixer.play_music(music, -1)
  end

  def play_sound(sound, channel)
    Mixer.play_channel(channel, sound, 0)
    @channels[channel] = false
  end

  def play(playfield)
    @channels = @channels.map { |ch| true }
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock
          play_sound(@swap, 0)   if block.state.class == SwappingState && block.state.counter == 1
          play_sound(@bounce, 1) if block.state.class == BouncingState && block.state.counter == 0
          play_sound(@bonus, 2)  if block.effects.any? { |e| e.counter == 1 }
        end
      end
    end
    
  end

end