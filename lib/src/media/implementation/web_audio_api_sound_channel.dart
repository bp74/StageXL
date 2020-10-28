part of stagexl.media;

class WebAudioApiSoundChannel extends SoundChannel {
  final WebAudioApiSound _webAudioApiSound;
  late SoundTransform _soundTransform;
  late final WebAudioApiMixer _mixer;

  late AudioBufferSourceNode _sourceNode;
  StreamSubscription<html.Event>? _sourceNodeEndedSubscription;

  bool _stopped = false;
  bool _paused = true;
  bool _loop = false;
  num _startTime = 0.0;
  num _duration = 0.0;
  num _position = 0.0;
  num _timeOffset = 0.0;

  WebAudioApiSoundChannel(WebAudioApiSound webAudioApiSound, num startTime,
      num duration, bool loop, [SoundTransform? soundTransform])
        : _webAudioApiSound = webAudioApiSound {
    _soundTransform = soundTransform ?? SoundTransform();
    _startTime = startTime.toDouble();
    _duration = duration.toDouble();
    _loop = loop;

    _mixer = WebAudioApiMixer(SoundMixer._webAudioApiMixer!.inputNode);
    _mixer.applySoundTransform(_soundTransform);

    paused = false;
  }

  //---------------------------------------------------------------------------

  @override
  bool get loop => _loop;

  @override
  bool get stopped => _stopped;

  @override
  Sound get sound => _webAudioApiSound;

  //---------------------------------------------------------------------------

  @override
  num get position {
    if (_paused || _stopped) {
      return _position;
    } else {
      var currentTime = WebAudioApiMixer.audioContext.currentTime!;
      var position = currentTime - _timeOffset;
      return _loop ? position % _duration : position.clamp(0.0, _duration);
    }
  }

  @override
  set position(num value) {
    var position = _loop ? value % _duration : value.clamp(0.0, _duration);
    if (_stopped) {
      // do nothing
    } else if (_paused) {
      _position = position;
    } else {
      paused = true;
      _position = position;
      paused = false;
    }
  }

  //---------------------------------------------------------------------------

  @override
  bool get paused => _paused;

  @override
  set paused(bool value) {
    if (_paused == value) {
      // nothing has changed
    } else if (_stopped) {
      // we can't pause/resume the audio playback.
      _paused = _stopped || value;
    } else if (value) {
      _position = position;
      _paused = true;
      _sourceNodeEndedSubscription?.cancel();
      _sourceNode.stop(0);
    } else if (_loop) {
      _paused = false;
      _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
      _sourceNode.buffer = _webAudioApiSound._audioBuffer;
      _sourceNode.loop = true;
      _sourceNode.loopStart = _startTime;
      _sourceNode.loopEnd = _startTime + _duration;
      _sourceNode.connectNode(_mixer.inputNode!);
      _sourceNode.start(0, _startTime + _position);
      _timeOffset = WebAudioApiMixer.audioContext.currentTime! - _position;
    } else {
      _paused = false;
      _sourceNode = WebAudioApiMixer.audioContext.createBufferSource();
      _sourceNode.buffer = _webAudioApiSound._audioBuffer;
      _sourceNode.loop = false;
      _sourceNode.connectNode(_mixer.inputNode!);
      _sourceNode.start(0, _startTime + _position, _duration - _position);
      _sourceNodeEndedSubscription = _sourceNode.onEnded.listen(_onEnded);
      _timeOffset = WebAudioApiMixer.audioContext.currentTime! - _position;
    }
  }

  @override
  SoundTransform get soundTransform => _soundTransform;

  @override
  set soundTransform(SoundTransform value) {
    _soundTransform = value;
    _mixer.applySoundTransform(_soundTransform);
  }

  //---------------------------------------------------------------------------

  @override
  void stop() {
    if (_stopped == false) {
      _sourceNode.stop(0);
      _sourceNodeEndedSubscription?.cancel();
      _onEnded(null);
    }
  }

  //---------------------------------------------------------------------------

  void _onEnded(html.Event? e) {
    if (_paused == false && _stopped == false && _loop == false) {
      _position = position;
      _stopped = true;
      _paused = true;
      dispatchEvent(Event(Event.COMPLETE));
    }
  }
}
