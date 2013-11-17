part of stagexl;

class AudioElementMixer {

  List<AudioElementSoundChannel> _soundChannels = new List<AudioElementSoundChannel>();
  num _mixerVolume = 1.0;

  applySoundTransform(SoundTransform value) {
    _mixerVolume = value.volume;
    _soundChannels.forEach(_updateSoundChannel);
  }

  //-----------------------------------------------------------------------------------------------

  _addSoundChannel(AudioElementSoundChannel audioElementSoundChannel) {
    _soundChannels.add(audioElementSoundChannel);
  }

  _removeSoundChannel(AudioElementSoundChannel audioElementSoundChannel) {
    _soundChannels.remove(audioElementSoundChannel);
  }

  _updateSoundChannel(AudioElementSoundChannel audioElementSoundChannel) {

    var audio = audioElementSoundChannel._audio;
    var channelVolume = audioElementSoundChannel._soundTransform.volume;

    if (audio != null) {
      audio.volume = _mixerVolume * channelVolume;
    }
  }
}