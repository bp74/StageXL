part of stagexl;

class AudioElementSoundChannel extends SoundChannel {
  
  AudioElementSound _audioElementSound;
  AudioElement _audio;

  bool _loop;
  SoundTransform _soundTransform;

  AudioElementSoundChannel(AudioElementSound audioElementSound, bool loop, SoundTransform soundTransform) {
    
    _audioElementSound = audioElementSound;
    _loop = loop;
    _soundTransform = soundTransform;

    _audio = audioElementSound._getAudioElement(this);
    _audio.loop = _loop;

    this.soundTransform = soundTransform;

    _audio.play();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {
    
    _soundTransform = value;

    if (_audio != null)
      _audio.volume = (_soundTransform != null) ? _soundTransform.volume : 1;
  }

  //-------------------------------------------------------------------------------------------------

  void stop() {
    
    if (_audio != null) {
      
      if (_audio.ended == false)
        _audio.pause();

      _audioElementSound._releaseAudioElement(this);
      _audio = null;
    }
  }

}
