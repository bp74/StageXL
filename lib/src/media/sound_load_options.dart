part of stagexl;

class SoundLoadOptions {
  
  /**
   *  The application provides *mp3* files as an option to load audio files.
   */
  bool mp3;
  
  /**
   *  The application provides *mp4* files as an option to load audio files.
   */
  bool mp4;
  
  /**
   *  The application provides *ogg* files as an option to load audio files.
   */
  bool ogg;
  
  /**
   *  The application provides *wav* files as an option to load audio files.
   */
  bool wav;
  
  /**
   *  Ignore loading errors and use a silent audio sample instead.
   */
  bool ignoreErrors;
  
  SoundLoadOptions({
    this.mp3: false, 
    this.mp4: false, 
    this.ogg: false, 
    this.wav: false, 
    this.ignoreErrors: true
  });
}