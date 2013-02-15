part of dartflash;

class MockSound extends Sound {
  
  MockSound() {
    // nothing to do
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<Sound> load(String url) {
    return new Future<Sound>.of(() => new MockSound());
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get length {
    // ToDo: We could load the WAV-file, parse the header and get the correct length!
    return double.NAN;
  }


  SoundChannel play([bool loop = false, SoundTransform soundTransform]) {
    
    if (soundTransform == null) {
      soundTransform = new SoundTransform();
    }
    
    return new MockSoundChannel(this, loop, soundTransform);
  }
}

