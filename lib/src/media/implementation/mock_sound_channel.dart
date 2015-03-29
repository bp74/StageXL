part of stagexl.media;

class MockSoundChannel extends SoundChannel {

  MockSound _mockSound;
  bool _stopped = false;
  bool _paused = false;
  bool _loop = false;
  num _startTime = 0.0;
  num _duration = 0.0;
  num _position = 0.0;

  SoundTransform _soundTransform;

  MockSoundChannel(
      MockSound mockSound,
      num startTime, num duration, bool loop,
      SoundTransform soundTransform) {

    if (soundTransform == null) soundTransform = new SoundTransform();

    _mockSound = mockSound;
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

  //---------------------------------------------------------------------------

  @override
  bool get paused {
    return _paused;
  }

  @override
  void set paused(bool value) {
    _paused = _stopped || value;
  }

  @override
  SoundTransform get soundTransform {
    return _soundTransform;
  }

  @override
  void set soundTransform(SoundTransform value) {
    _soundTransform = value;
  }

  //---------------------------------------------------------------------------

  @override
  void stop() {
    if (_stopped == false) {
      _stopped = true;
      _paused = true;
      this.dispatchEvent(new Event(Event.COMPLETE));
    }
  }

}
