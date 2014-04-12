part of stagexl;

class SoundLoadOptions {

  /// The application provides *mp3* files as an option to load audio files.
  ///
  bool mp3;

  /// The application provides *mp4* files as an option to load audio files.
  ///
  bool mp4;

  /// The application provides *ogg* files as an option to load audio files.
  ///
  bool ogg;

  /// The application provides *ac3* files as an option to load audio files.
  ///
  bool ac3;

  /// The application provides *wav* files as an option to load audio files.
  ///
  bool wav;

  /// A list of alternative urls for sound samples in the case where the
  /// primary url does not work or the file type is not supported by the
  /// browser. If this value is null, the alternative urls are calcualted
  /// automatically based on the mp3, mp4, ogg, ac3 and wav properties.
  ///
  List<String> alternativeUrls;

  /// Ignore loading errors and use a silent audio sample instead.
  ///
  bool ignoreErrors;

  SoundLoadOptions({
    this.mp3: false,
    this.mp4: false,
    this.ogg: false,
    this.ac3: false,
    this.wav: false,
    this.alternativeUrls: null,
    this.ignoreErrors: true
  });

  SoundLoadOptions clone() => new SoundLoadOptions(
      mp3: this.mp3, mp4: this.mp4, ogg: this.ogg, ac3: this.ac3, wav: this.wav,
      alternativeUrls: this.alternativeUrls, ignoreErrors: this.ignoreErrors);
}