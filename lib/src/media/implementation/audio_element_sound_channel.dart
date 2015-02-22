part of stagexl.media;

class AudioElementSoundChannel extends SoundChannel {

  final AudioElementSound _audioElementSound;
  AudioElement _audioElement;

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
      _soundTransform = soundTransform != null ? soundTransform : new SoundTransform() {

    audioElementSound._requestAudioElement(this).then(_onAudioElement);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  void set soundTransform(SoundTransform value) {
    _soundTransform = value != null ? value : new SoundTransform();
    if (_audioElement != null) {
      var volume1 = _soundTransform.volume;
      var volume2 = SoundMixer._audioElementMixer.volume;
      _audioElement.volume = volume1 * volume2;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void stop() {

    _stopped = true;

    if (_audioElement == null) return;
    if (_audioElement.ended == false) _audioElement.pause();
    if (_volumeChangedSubscription != null) _volumeChangedSubscription.cancel();
    if (_segmentTimer != null) _segmentTimer.cancel();

    _audioElementSound._releaseAudioElement(_audioElement);
    _audioElement = null;
    _volumeChangedSubscription = null;
    _segmentTimer = null;
  }

  //-------------------------------------------------------------------------------------------------

  _onAudioElement(AudioElement audioElement) {

    var mixer = SoundMixer._audioElementMixer;

    if (_stopped) {

      _audioElementSound._releaseAudioElement(audioElement);

    } else {

      _audioElement = audioElement;
      _audioElement.loop = _loop;
      _audioElement.currentTime = _segmentStartTime;
      _audioElement.volume = _soundTransform.volume * mixer.volume;
      _audioElement.play();

      if (_segmentStartTime != 0 || _segmentDuration.inSeconds != 3600) {
        _segmentTimer = new Timer(_segmentDuration, _onSegmentTimer);
      }

      _volumeChangedSubscription = mixer.onVolumeChanged.listen(_onMixerVolume);
    }
  }

  //-------------------------------------------------------------------------------------------------

  _onSegmentTimer() {

    if (_loop == false) this.stop();
    if (_loop == false) return;

    _audioElement.currentTime = _segmentStartTime;
    _segmentTimer = new Timer(_segmentDuration, _onSegmentTimer);
  }

  //-------------------------------------------------------------------------------------------------

  _onMixerVolume(num volume) {
    _audioElement.volume = _soundTransform.volume * volume;
  }
}
