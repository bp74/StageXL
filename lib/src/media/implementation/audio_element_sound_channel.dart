part of stagexl;

class AudioElementSoundChannel extends SoundChannel {

  AudioElementSound _audioElementSound;
  AudioElement _audio;

  bool _loop;
  SoundTransform _soundTransform;
  List<num> _segment;
  StreamSubscription _pauser;

  AudioElementSoundChannel(AudioElementSound audioElementSound, bool loop, SoundTransform soundTransform, List<num> segment) {

    _audioElementSound = audioElementSound;
    _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform();
    _loop = loop;
    _segment = segment;

    _audio = audioElementSound._getAudioElement(this);
    SoundMixer._audioElementMixer._updateSoundChannel(this);
    
    _audio.currentTime = _segment[0];
    
    _audio.loop = _loop;
    if(_audio.duration != segment[1]) {
      var future = new Future.delayed(new Duration(milliseconds: (segment[1]*1000).toInt()));
      _pauser = future.asStream().listen((e) {
        if(_audio.loop) _audio.currentTime = _segment[0];
        else this.stop();
      });
    }
    
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
      if(_pauser != null) _pauser.cancel();
      _audioElementSound._releaseAudioElement(this);
      _audio = null;
    }
  }

}
