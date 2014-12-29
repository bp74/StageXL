part of stagexl.media;

class AudioElementSoundChannel extends SoundChannel {

  final AudioElementSound _audioElementSound;
  AudioElement _audio;

  final bool _loop;
  bool _stopped = false;

  SoundTransform _soundTransform;
  StreamSubscription _volumeChangedSubscription;

  num _segmentStartTime;
  Duration _segmentDuration;
  Timer _segmentTimer;

  AudioElementSoundChannel(AudioElementSound audioElementSound,
      num startTime, num duration, bool loop, SoundTransform soundTransform) :

      _audioElementSound = audioElementSound,
      _segmentStartTime = startTime,
      _segmentDuration = new Duration(milliseconds: (duration * 1000).round()),
      _loop = loop,
      _soundTransform = (soundTransform != null) ? soundTransform : new SoundTransform() {

    audioElementSound._requestAudioElement(this).then(_onAudioElement);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {
    _soundTransform = value != null ? value : new SoundTransform();
    if (_audio != null) {
      var volume1 = _soundTransform.volume;
      var volume2 = SoundMixer._audioElementMixer.volume;
      _audio.volume = volume1 * volume2;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void stop() {

    _stopped = true;

    if (_audio == null) return;
    if (_audio.ended == false) _audio.pause();
    if (_volumeChangedSubscription != null) _volumeChangedSubscription.cancel();
    if (_segmentTimer != null) _segmentTimer.cancel();

    _audioElementSound._releaseAudioElement(this, _audio);
    _audio = null;
    _volumeChangedSubscription = null;
    _segmentTimer = null;
  }

  //-------------------------------------------------------------------------------------------------

  _onAudioElement(AudioElement audio) {

    var audioElementMixer = SoundMixer._audioElementMixer;

    if (_stopped) {

      _audioElementSound._releaseAudioElement(this, audio);

    } else {

      _audio = audio;
      _audio.loop = _loop;
      _audio.currentTime = _segmentStartTime;
      _audio.volume = _soundTransform.volume * audioElementMixer.volume;
      _audio.play();

      if (_segmentStartTime != 0 || _segmentDuration.inSeconds != 3600) {
        _segmentTimer = new Timer(_segmentDuration, _onSegmentTimer);
      }

      _volumeChangedSubscription = audioElementMixer.onVolumeChanged.listen(_onMixerVolume);
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onSegmentTimer() {

    if (_loop == false) this.stop();
    if (_loop == false) return;

    _audio.currentTime = _segmentStartTime;
    _segmentTimer = new Timer(_segmentDuration, _onSegmentTimer);
  }

  //-------------------------------------------------------------------------------------------------

  _onMixerVolume(num volume) {
    _audio.volume = _soundTransform.volume * volume;
  }
}
