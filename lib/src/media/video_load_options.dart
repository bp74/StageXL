part of stagexl.media;

class VideoLoadOptions {

  /// The application provides *mp4* files as an option to load video files.
  bool mp4;

  /// The application provides *webm* files as an option to load video files.
  bool webm;

  /// The application provides *ogg* files as an option to load video files.
  bool ogg;

  /// A list of alternative urls for video files in the case where the
  /// primary url does not work or the file type is not supported by the
  /// browser. If this value is null, the alternative urls are calcualted
  /// automatically based on the mp3, mp4, ogg, ac3 and wav properties.

  List<String> alternativeUrls;

  /// load the data from the video file
  /// so the src of the VideoElement is
  /// a base64 encode video data
  /// and not a url
  bool loadData;

  //---------------------------------------------------------------------------

  VideoLoadOptions({
      this.mp4: false,
      this.webm: false,
      this.ogg: false,
      this.alternativeUrls: null,
      this.loadData: false
    });

  VideoLoadOptions clone() => new VideoLoadOptions(
      mp4: this.mp4, webm: this.webm, ogg: this.ogg,
      alternativeUrls: this.alternativeUrls,
      loadData: loadData);
}
