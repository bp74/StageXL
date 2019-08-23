part of stagexl.media;

class MockSound extends Sound {
  MockSound._();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions]) {
    return Future<Sound>.value(MockSound._());
  }

  static Future<Sound> loadDataUrl(String dataUrl,
      [SoundLoadOptions soundLoadOptions]) {
    return Future<Sound>.value(MockSound._());
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  @override
  SoundEngine get engine => SoundEngine.Mockup;

  @override
  num get length {
    // We could load the WAV-file, parse the header and get the correct length!
    return double.nan;
  }

  @override
  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    return MockSoundChannel(this, 0, this.length, loop, soundTransform);
  }

  @override
  SoundChannel playSegment(num startTime, num duration,
      [bool loop = false, SoundTransform soundTransform]) {
    return MockSoundChannel(this, startTime, duration, loop, soundTransform);
  }
}
