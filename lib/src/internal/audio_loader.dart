library stagexl.internal.audio_loader;

import 'dart:async';
import 'dart:html';

class AudioLoader {

  final AudioElement audio = new AudioElement();
  final Completer<AudioElement> _completer = new Completer<AudioElement>();

  List<String> _urls = new List<String>();
  bool _loadData = false;

  StreamSubscription _onCanPlaySubscription;
  StreamSubscription _onErrorSubscription;

  AudioLoader(List<String> urls, bool loadData, bool corsEnabled) {

    if (corsEnabled) {
      audio.crossOrigin = 'anonymous';
    }

    _urls.addAll(urls);
    _loadData = loadData;
    _onCanPlaySubscription = audio.onCanPlay.listen((e) => _loadDone());
    _onErrorSubscription = audio.onError.listen((e) => _loadNextUrl());
    _loadNextUrl();
  }

  Future<AudioElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _loadNextUrl() {
    if (_urls.length == 0) {
      _loadFailed();
    } else if (_loadData) {
      _loadAudioData(_urls.removeAt(0));
    } else {
      _loadAudioSource(_urls.removeAt(0));
    }
  }

  void _loadFailed() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.completeError(new StateError("Failed to load audio."));
  }

  void _loadDone() {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(audio);
  }

  void _loadAudioData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      var reader = new FileReader();
      reader.readAsDataUrl(request.response);
      reader.onLoadEnd.first.then((e) {
        if(reader.readyState == FileReader.DONE) {
          _loadAudioSource(reader.result);
        } else {
          _loadFailed();
        }
      });
    }).catchError((error) {
      _loadNextUrl();
    });
  }

  void _loadAudioSource(String url) {
    audio.preload = "auto";
    audio.src = url;
    audio.load();
  }

}
