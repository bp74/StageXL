library stagexl.internal.video_loader;

import 'dart:async';
import 'dart:html';

import '../errors.dart';

class VideoLoader {
  static final List<String> supportedTypes = _getSupportedTypes();

  final VideoElement video = VideoElement();
  final AggregateError aggregateError = AggregateError('Error loading video.');
  final Completer<VideoElement> _completer = Completer<VideoElement>();

  late StreamSubscription<Event> _onCanPlaySubscription;
  late StreamSubscription<Event> _onErrorSubscription;
  final List<String> _urls = <String>[];
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
    final ve = event.target as VideoElement;
    final loadError = LoadError('Failed to load ${ve.src}.', ve.error);
    aggregateError.errors.add(loadError);
    _loadNextUrl();
  }

  void _loadNextUrl() {
    if (_urls.isEmpty) {
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
    if (aggregateError.errors.isEmpty) {
      final loadError = LoadError('No configured video type is supported.');
      aggregateError.errors.add(loadError);
    }
    _completer.completeError(aggregateError);
  }

  void _loadVideoData(String url) {
    HttpRequest.request(url, responseType: 'blob').then((request) {
      final reader = FileReader();
      reader.readAsDataUrl(request.response as Blob);
      reader.onLoadEnd.first
          .then((e) => _loadVideoSource(reader.result as String));
    }).catchError((error) {
      final loadError = LoadError('Failed to load $url.', error);
      aggregateError.errors.add(loadError);
      _loadNextUrl();
    });
  }

  void _loadVideoSource(String url) {
    video.preload = 'auto';
    video.src = url;
    video.load();
  }

  //---------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {
    final supportedTypes = <String>[];
    final video = VideoElement();
    final valid = ['maybe', 'probably'];

    if (valid.contains(video.canPlayType('video/webm'))) {
      supportedTypes.add('webm');
    }
    if (valid.contains(video.canPlayType('video/mp4'))) {
      supportedTypes.add('mp4');
    }
    if (valid.contains(video.canPlayType('video/ogg'))) {
      supportedTypes.add('ogg');
    }

    print('StageXL video types   : $supportedTypes');
    return supportedTypes.toList(growable: false);
  }
}
