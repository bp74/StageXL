part of stagexl;

class MockSound extends Sound {

  MockSound._();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {
    return new Future<Sound>.value(new MockSound._());
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length {
    // ToDo: We could load the WAV-file, parse the header and get the correct length!
    return double.NAN;
  }

  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    if (soundTransform == null) soundTransform = new SoundTransform();
    return new MockSoundChannel(this, 0, this.length, loop, soundTransform);
  }

  SoundChannel playSegment(num startTime, num duration, [
                           bool loop = false, SoundTransform soundTransform]) {

    if (soundTransform == null) soundTransform = new SoundTransform();
    return new MockSoundChannel(this, startTime, duration, loop, soundTransform);
  }
}
