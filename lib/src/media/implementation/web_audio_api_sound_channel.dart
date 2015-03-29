part of stagexl.media;

class WebAudioApiSoundChannel extends SoundChannel {

  WebAudioApiSound _webAudioApiSound;
  SoundTransform _soundTransform;
  WebAudioApiMixer _webAudioApiMixer;
  AudioBufferSourceNode _sourceNode;
  Timer _completeTimer;

  bool _stopped = false;
  bool _paused = true;
  bool _loop = false;
  num _startTime = 0.0;
  num _duration = 0.0;
  num _position = 0.0;
  num _timeOffset = 0.0;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound,
                          num startTime, num duration, bool loop,
                          SoundTransform soundTransform) {

    if (soundTransform == null) soundTransform = new SoundTransform();

    _webAudioApiSound = webAudioApiSound;
    _startTime = startTime.toDouble();
    _duration = duration.toDouble();
    _soundTransform = soundTransform;
    _loop = loop;

    _webAudioApiMixer = new WebAudioApiMixer(SoundMixer._webAudioApiMixer.inputNode);
    _webAudioApiMixer.applySoundTransform(_soundTransform);

    this.paused = false;
  }

  //---------------------------------------------------------------------------

  @override
  bool get loop => _loop;

  @override
  bool get stopped => _stopped;

  @override
  Sound get sound => _webAudioApiSound;

  @override
  num get position {
    if (_paused || _stopped) {
      return _position;
    } else {
      var currentTime = WebAudioApiMixer.audioContext.currentTime;
      var position = currentTime - _timeOffset;
      var duration = _duration;
      return _loop ? position % duration : position.clamp(0.0, duration);
    }
  }

  //---------------------------------------------------------------------------

  @override
  bool get paused {
    return _paused;
  }

  @override
  void set paused(bool value) {
    if (_paused == value) {
      // nothing has changed
    } else if (_stopped) {
      // we can't pause/resume the audio playback.
      _paused = _stopped || value;
    } else if (value){
      _position = this.position;
      _paused = true;
      _sourceNode.stop(0);
      _stopCompleteTimer();
    } else if (_loop) {
      _paused = false;
      _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
      _sourceNode.buffer = _webAudioApiSound._audioBuffer;
      _sourceNode.loop = true;
      _sourceNode.loopStart = _startTime;
      _sourceNode.loopEnd = _startTime + _duration;
      _sourceNode.connectNode(_webAudioApiMixer.inputNode);
      _sourceNode.start(0, _startTime + _position);
      _timeOffset = WebAudioApiMixer.audioContext.currentTime - _position;
    } else {
      _paused = false;
      _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
      _sourceNode.buffer = _webAudioApiSound._audioBuffer;
      _sourceNode.loop = false;
      _sourceNode.connectNode(_webAudioApiMixer.inputNode);
      _sourceNode.start(0, _startTime + _position, _duration - _position);
      _timeOffset = WebAudioApiMixer.audioContext.currentTime - _position;
      _startCompleteTimer(_duration - _position);
    }
  }

  @override
  SoundTransform get soundTransform {
    return _soundTransform;
  }

  @override
  void set soundTransform(SoundTransform value) {
    _soundTransform = value != null ? value : new SoundTransform();
    _webAudioApiMixer.applySoundTransform(value);
  }

  //---------------------------------------------------------------------------

  @override
  void stop() {
    if (_stopped == false) {
      _sourceNode.stop(0);
      _stopCompleteTimer();
      _onCompleteTimer();
    }
  }

  //---------------------------------------------------------------------------

  void _startCompleteTimer(num time) {
    // This is a workaround for the broken onEnded event :(
    // Replace the timer with the onEnded event as soon as possible.
    // https://code.google.com/p/chromium/issues/detail?id=349543
    time = time.clamp(0.0, _duration) * 1000.0;
    var duration = new Duration(milliseconds: time.toInt());
    _completeTimer = new Timer(duration, _onCompleteTimer);
  }

  void _stopCompleteTimer() {
    if (_completeTimer != null) {
      _completeTimer.cancel();
      _completeTimer = null;
    }
  }

  void _onCompleteTimer() {
    if (_paused || _stopped || _loop) {
      // Called by accident
    } else {
      _position = this.position;
      _stopped = true;
      _paused = true;
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

}
