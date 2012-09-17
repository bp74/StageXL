class MockSound extends Sound 
{
  MockSound()
  {
    // nothing to do
  }
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------
  
  Future<Sound> load(String url)
  {
    var loadCompleter = new Completer<Sound>();
    
    html.window.setTimeout(() => loadCompleter.complete(this), 1);
    
    return  loadCompleter.future;
  }
  
  num get length() 
  {
    // ToDo: We could load the WAV-file, parse the header and get the correct length!
    return double.NAN;
  }

  
  SoundChannel play([bool loop = false, SoundTransform soundTransform = null]) 
  {
    if (soundTransform == null)
      soundTransform = new SoundTransform();
    
    return new MockSoundChannel(this, loop, soundTransform);
  }
}

