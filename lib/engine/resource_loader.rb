
class ResourceLoader

  def self.data_dir
    return File.join(File.dirname(__FILE__), "..", "data")
  end
  
  def self.load(filename)
    return Surface.load((File.join(data_dir, "img", filename + '.png')))
  end

  def self.load_music(filename)
    return Mixer::Music.load((File.join(data_dir, "sound", filename + '.ogg')))
  end

  def self.load_wave(filename)
    return Mixer::Wave.load((File.join(data_dir, "sound", filename + '.ogg')))
  end

end
