part of stagexl;

class MockSound extends Sound {

  MockSound() {

  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url, [SoundLoadOptions soundLoadOptions = null]) {
    return new Future<Sound>.value(new MockSound());
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length {
    // ToDo: We could load the WAV-file, parse the header and get the correct length!
    return double.NAN;
  }


  SoundChannel play([bool loop = false, SoundTransform soundTransform, List<num> segment]) {

    if (soundTransform == null) soundTransform = new SoundTransform();
    if(segment == null) segment = [0.0, length];

    return new MockSoundChannel(this, loop, soundTransform, segment);
  }
}

