part of stagexl;

class MockSoundChannel extends SoundChannel {
  
  bool _loop;
  SoundTransform _soundTransform;

  MockSoundChannel(MockSound mockSound, bool loop, SoundTransform soundTransform) {
    _loop = loop;
    _soundTransform = soundTransform;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  SoundTransform get soundTransform => _soundTransform;

  set soundTransform(SoundTransform value) {
    _soundTransform = value;
  }

  void stop() {
    // nothing to do
  }
}
