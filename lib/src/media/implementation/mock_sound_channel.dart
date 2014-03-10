part of stagexl;

class MockSoundChannel extends SoundChannel {
  
  bool _loop;
  SoundTransform _soundTransform;
  List<num> _segment;

  MockSoundChannel(MockSound mockSound, bool loop, SoundTransform soundTransform, List<num> segment) {
    _loop = loop;
    _soundTransform = soundTransform;
    _segment = segment;
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
