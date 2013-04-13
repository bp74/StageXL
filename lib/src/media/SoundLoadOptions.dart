part of stagexl;

class SoundLoadOptions {
  
  /// Fallback to mp3-file if the browser does not support the supplied file type.
  bool mp3;
  /// Fallback to mp4-file if the browser does not support the supplied file type.
  bool mp4;
  /// Fallback to ogg-file if the browser does not support the supplied file type.
  bool ogg;
  /// Fallback to wav-file if the browser does not support the supplied file type.  
  bool wav;
  
  /// Ignore all loading errors.
  bool ignoreErrors;
  
  SoundLoadOptions({
    this.mp3: false, 
    this.mp4: false, 
    this.ogg: false, 
    this.wav: false, 
    this.ignoreErrors: true
  });
}