part of stagexl.media;

class AudioElementSoundChannel extends SoundChannel {
  AudioElementSound? _audioElementSound;
  SoundTransform? _soundTransform;
  AudioElement? _audioElement;
  StreamSubscription? _volumeChangedSubscription;
  Timer? _completeTimer;

  bool _stopped = false;
  bool _paused = false;
  bool _loop = false;
  num _startTime = 0.0;
  num _duration = 0.0;
  num _position = 0.0;

  AudioElementSoundChannel(AudioElementSound audioElementSound, num startTime,
      num duration, bool loop, SoundTransform? soundTransform) {
    _soundTransform = soundTransform ?? SoundTransform();
    _audioElementSound = audioElementSound;
    _startTime = startTime.toDouble();
    _duration = duration.toDouble();
    _loop = loop;

    audioElementSound._requestAudioElement(this).then(_onAudioElement);
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  bool get loop => _loop;

  @override
  bool get stopped => _stopped;

  @override
  Sound? get sound => _audioElementSound;

  //---------------------------------------------------------------------------

  @override
  num get position {
    if (_paused || _stopped || _audioElement == null) {
      return _position;
    } else {
      var currentTime = _audioElement!.currentTime;
      return (currentTime - _startTime).clamp(0.0, _duration);
    }
  }

  @override
  set position(num value) {
    var position = _loop ? value % _duration : value.clamp(0.0, _duration);
    if (_stopped) {
      // do nothing
    } else if (_paused || _audioElement == null) {
      _position = position;
    } else {
      _stopCompleteTimer();
      _position = position;
      _audioElement!.currentTime = _startTime + _position;
      _startCompleteTimer(_duration - _position);
    }
  }

  //---------------------------------------------------------------------------

  @override
  bool get paused {
    return _paused;
  }

  @override
  set paused(bool value) {
    if (_paused == value) {
      // nothing has changed
    } else if (_audioElement == null || _stopped) {
      // we can't pause/resume the audio playback.
      _paused = _stopped || value;
    } else if (value) {
      _position = position;
      _paused = true;
      _audioElement!.pause();
      _stopCompleteTimer();
    } else {
      _paused = false;
      _audioElement!.currentTime = _startTime + _position;
      _audioElement!.play();
      _startCompleteTimer(_duration - _position);
    }
  }

  @override
  SoundTransform? get soundTransform {
    return _soundTransform;
  }

  @override
  set soundTransform(SoundTransform? value) {
    _soundTransform = value ?? SoundTransform();
    if (_audioElement == null) {
      // we can't set the audio element
    } else {
      var volume1 = _soundTransform!.volume;
      var volume2 = SoundMixer._audioElementMixer!.volume;
      _audioElement!.volume = volume1 * volume2;
    }
  }

  //---------------------------------------------------------------------------

  @override
  void stop() {
    if (_audioElement != null) {
      _position = position;
      _audioElement!.pause();
      _audioElement!.currentTime = 0;
      _audioElementSound!._releaseAudioElement(_audioElement!);
      _audioElement = null;
    }
    if (_volumeChangedSubscription != null) {
      _volumeChangedSubscription!.cancel();
      _volumeChangedSubscription = null;
    }
    if (_stopped == false) {
      _stopped = true;
      _paused = true;
      _stopCompleteTimer();
      dispatchEvent(Event(Event.COMPLETE));
    }
  }

  //---------------------------------------------------------------------------

  void _onAudioElement(AudioElement audioElement) {
    var mixer = SoundMixer._audioElementMixer;

    if (_stopped) {
      _audioElementSound!._releaseAudioElement(audioElement);
    } else {
      _audioElement = audioElement;
      _audioElement!.volume = _soundTransform!.volume * mixer!.volume;
      _volumeChangedSubscription =
          mixer.onVolumeChanged.listen(_onVolumeChanged);
      if (_paused == false) {
        _audioElement!.currentTime = _startTime + _position;
        _audioElement!.play();
        _startCompleteTimer(_duration - _position);
      }
    }
  }

  //---------------------------------------------------------------------------

  void _startCompleteTimer(num time) {
    time = time.clamp(0.0, _duration) * 1000.0;
    var duration = Duration(milliseconds: time.toInt());
    _completeTimer = Timer(duration, _onCompleteTimer);
  }

  void _stopCompleteTimer() {
    _completeTimer?.cancel();
    _completeTimer = null;
  }

  void _onCompleteTimer() {
    if (paused) {
      // called by accident
    } else if (loop) {
      _audioElement!.currentTime = _startTime;
      _audioElement!.play();
      _startCompleteTimer(_duration);
    } else {
      stop();
    }
  }

  void _onVolumeChanged(num volume) {
    _audioElement!.volume = _soundTransform!.volume * volume;
  }

  void _onAudioEnded() {
    if (loop) {
      // The loop is restarted by the complete timer.
    } else {
      stop();
    }
  }
}
