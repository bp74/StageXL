part of stagexl.media;

class MockSoundChannel extends SoundChannel {
  final MockSound _mockSound;
  bool _stopped = false;
  bool _paused = false;
  bool _loop = false;

  late SoundTransform _soundTransform;

  MockSoundChannel(MockSound mockSound, bool loop,
      [SoundTransform? soundTransform])
      : _mockSound = mockSound {
    soundTransform ??= SoundTransform();

    _soundTransform = soundTransform;
    _loop = loop;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  bool get loop => _loop;

  @override
  bool get stopped => _stopped;

  @override
  num get position => 0.0;

  @override
  Sound get sound => _mockSound;

  @override
  set position(num value) => Never;

  //---------------------------------------------------------------------------

  @override
  bool get paused => _paused;

  @override
  set paused(bool value) {
    _paused = _stopped || value;
  }

  @override
  SoundTransform get soundTransform => _soundTransform;

  @override
  set soundTransform(SoundTransform value) {
    _soundTransform = value;
  }

  //---------------------------------------------------------------------------

  @override
  void stop() {
    if (_stopped == false) {
      _stopped = true;
      _paused = true;
      dispatchEvent(Event(Event.COMPLETE));
    }
  }
}
