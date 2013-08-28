part of stagexl;

class AudioElementSoundChannel extends SoundChannel {

  AudioElementSound _audioElementSound;
  AudioElement _audio;

  bool _loop;
  SoundTransform _soundTransform;

  AudioElementSoundChannel(AudioElementSound audioElementSound, bool loop, SoundTransform soundTransform) {

    _audioElementSound = audioElementSound;
    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _loop = loop;

    _audio = audioElementSound._getAudioElement(this);
    SoundMixer._audioElementMixer._updateSoundChannel(this);

    _audio.loop = _loop;
    _audio.play();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {

    _soundTransform = (value != null) ? value : new SoundTransform();
    SoundMixer._audioElementMixer._updateSoundChannel(this);
  }

  //-------------------------------------------------------------------------------------------------

  void stop() {

    if (_audio != null) {
      if (_audio.ended == false) _audio.pause();
      _audioElementSound._releaseAudioElement(this);
      _audio = null;
    }
  }

}
