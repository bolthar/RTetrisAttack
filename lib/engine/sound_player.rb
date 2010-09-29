
class SoundPlayer

  def initialize
    @pop    = ResourceLoader.load_wave('pop')
    @swap   = ResourceLoader.load_wave('swap')
    @bounce = ResourceLoader.load_wave('bounce')
    @bonus  = ResourceLoader.load_wave('bonus')

    @music  = ResourceLoader.load_music('music')
    @danger = ResourceLoader.load_music('danger')
  end

  def play_music(music)
    if @playing_music != music
      @playing_music = music
      Mixer.play_music(music, -1)
    end
  end

  def play_sound(sound, channel)
    if channel.kind_of? Array
      target_channel = channel.first { |ch| !Mixer.play?(ch) }
      Mixer.play_channel(target_channel, sound, 0) if target_channel
    else
      Mixer.play_channel(channel, sound, 0) unless Mixer.play?(channel)
    end
  end

  def play(playfield)
    over_threshold = false
    (0..5).each do |x|
      (0..11).each do |y|
        block = playfield[x,y]
        unless block.class == NilBlock
          play_sound(@swap, 0)   if block.state.class == SwappingState && block.state.counter == 1
          play_sound(@bounce, 1) if block.state.class == BouncingState && block.state.counter == 0
          play_sound(@bonus, 2)  if block.effects.any? { |e| e.counter == 1 }
          play_sound(@pop, [3,4,5,6])    if block.state.class == ExplodingState && block.state.exploding?
          over_threshold = true if y > 8
        end
      end
    end
    play_music(over_threshold ? @danger : @music)    
  end

end