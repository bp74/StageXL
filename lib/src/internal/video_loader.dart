library stagexl.internal.video_loader;

import 'dart:async';
import 'dart:html';

import '../errors.dart';

class VideoLoader {

  static final List<String> supportedTypes = _getSupportedTypes();

  final VideoElement video = new VideoElement();
  final AggregateError aggregateError = new AggregateError("Error loading video.");
  final Completer<VideoElement> _completer = new Completer<VideoElement>();

  StreamSubscription _onCanPlaySubscription;
  StreamSubscription _onErrorSubscription;
  List<String> _urls = new List<String>();
  bool _loadData = false;

  VideoLoader(List<String> urls, bool loadData, bool corsEnabled) {

    if (corsEnabled) video.crossOrigin = 'anonymous';

    _onCanPlaySubscription = video.onCanPlay.listen(_onVideoCanPlay);
    _onErrorSubscription = video.onError.listen(_onVideoError);

    _urls.addAll(urls);
    _loadData = loadData;
    _loadNextUrl();
  }

  Future<VideoElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onVideoCanPlay(Event event) {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(video);
  }

  void _onVideoError(Event event) {
    var ve = event.target as VideoElement;
    var loadError = new LoadError("Failed to load ${ve.src}.", ve.error);
    aggregateError.errors.add(loadError);
    _loadNextUrl();
  }

  void _loadNextUrl() {
    if (_urls.length == 0) {
      _loadFailed();
    } else if (_loadData) {
      _loadVideoData(_urls.removeAt(0));
    } else {
      _loadVideoSource(_urls.removeAt(0));
    }
  }

  void _loadFailed() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    if (this.aggregateError.errors.length == 0) {
      var loadError = new LoadError("No configured video type is supported.");
      this.aggregateError.errors.add(loadError);
    }
    _completer.completeError(this.aggregateError);
  }

  void _loadVideoData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      var reader = new FileReader();
      reader.readAsDataUrl(request.response);
      reader.onLoadEnd.first.then((e) => _loadVideoSource(reader.result));
    }).catchError((error) {
      var loadError = new LoadError("Failed to load $url.", error);
      this.aggregateError.errors.add(loadError);
      _loadNextUrl();
    });
  }

  void _loadVideoSource(String url) {
    video.preload = "auto";
    video.src = url;
    video.load();
  }

  //---------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {

    var supportedTypes = new List<String>();
    var video = new VideoElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(video.canPlayType("video/webm")) != -1) supportedTypes.add("webm");
    if (valid.indexOf(video.canPlayType("video/mp4")) != -1) supportedTypes.add("mp4");
    if (valid.indexOf(video.canPlayType("video/ogg")) != -1) supportedTypes.add("ogg");

    print("StageXL video types   : $supportedTypes");

    return supportedTypes.toList(growable: false);
  }

}
