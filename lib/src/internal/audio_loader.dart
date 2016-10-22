library stagexl.internal.audio_loader;

import 'dart:async';
import 'dart:html';

import '../errors.dart';

class AudioLoader {

  static final List<String> supportedTypes = _getSupportedTypes();

  final AudioElement audio = new AudioElement();
  final AggregateError aggregateError = new AggregateError("Error loading sound.");
  final Completer<AudioElement> _completer = new Completer<AudioElement>();

  StreamSubscription _onCanPlaySubscription;
  StreamSubscription _onErrorSubscription;
  List<String> _urls = new List<String>();
  bool _loadData = false;

  AudioLoader(List<String> urls, bool loadData, bool corsEnabled) {

    // we have to add the AudioElement to the document,
    // otherwise some browser won't start loading :(

    document.body.children.add(audio);

    if (corsEnabled) audio.crossOrigin = 'anonymous';

    _urls.addAll(urls);
    _loadData = loadData;
    _onCanPlaySubscription = audio.onCanPlay.listen(_onAudioCanPlay);
    _onErrorSubscription = audio.onError.listen(_onAudioError);
    _loadNextUrl();
  }

  Future<AudioElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onAudioCanPlay(Event event) {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(audio);
  }

  void _onAudioError(Event event) {
    var ae = event.target as AudioElement;
    var loadError = new LoadError("Failed to load ${ae.src}.", ae.error);
    aggregateError.errors.add(loadError);
    _loadNextUrl();
  }

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
    if (this.aggregateError.errors.length == 0) {
      var loadError = new LoadError("No configured audio type is supported.");
      this.aggregateError.errors.add(loadError);
    }
    _completer.completeError(this.aggregateError);
  }

  void _loadAudioData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      var reader = new FileReader();
      reader.readAsDataUrl(request.response as Blob);
      reader.onLoadEnd.first.then((e) => _loadAudioSource(reader.result));
    }).catchError((error) {
      var loadError = new LoadError("Failed to load $url.", error);
      this.aggregateError.errors.add(loadError);
      _loadNextUrl();
    });
  }

  void _loadAudioSource(String url) {
    audio.preload = "auto";
    audio.src = url;
    audio.load();
  }

  //-------------------------------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {

    var supportedTypes = new List<String>();
    var audio = new AudioElement();
    var valid = ["maybe", "probably"];

    if (valid.indexOf(audio.canPlayType("audio/ogg; codecs=opus")) != -1) supportedTypes.add("opus");
    if (valid.indexOf(audio.canPlayType("audio/mpeg")) != -1) supportedTypes.add("mp3");
    if (valid.indexOf(audio.canPlayType("audio/mp4")) != -1) supportedTypes.add("mp4");
    if (valid.indexOf(audio.canPlayType("audio/ogg")) != -1) supportedTypes.add("ogg");
    if (valid.indexOf(audio.canPlayType("audio/ac3")) != -1) supportedTypes.add("ac3");
    if (valid.indexOf(audio.canPlayType("audio/wav")) != -1) supportedTypes.add("wav");

    print("StageXL audio types   : $supportedTypes");

    return supportedTypes.toList(growable: false);
  }

}
