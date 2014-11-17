library stagexl.internal.video_loader;

import 'dart:async';
import 'dart:html';

class VideoLoader {

  final VideoElement video = new VideoElement();
  final Completer<VideoElement> _completer = new Completer<VideoElement>();

  List<String> _urls = new List<String>();
  bool _loadData = false;

  StreamSubscription _onCanPlaySubscription;
  StreamSubscription _onErrorSubscription;

  VideoLoader(List<String> urls, bool loadData) {
    _urls.addAll(urls);
    _loadData = loadData;
    _onCanPlaySubscription = video.onCanPlayThrough.listen((e) => _loadDone());
    _onErrorSubscription = video.onError.listen((e) => _loadNextUrl());
    _loadNextUrl();
  }

  Future<VideoElement> get done => _completer.future;

  //---------------------------------------------------------------------------

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
    _completer.completeError(new StateError("Failed to load video."));
  }

  void _loadDone() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(video);
  }

  void _loadVideoData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      var reader = new FileReader();
      reader.readAsDataUrl(request.response);
      reader.onLoadEnd.first.then((e) {
        if(reader.readyState == FileReader.DONE) {
          _loadVideoSource(reader.result);
        } else {
          _loadFailed();
        }
      });
    }).catchError((error) {
      _loadNextUrl();
    });
  }

  void _loadVideoSource(String url) {
    video.preload = "auto";
    video.src = url;
    video.load();
  }

}
