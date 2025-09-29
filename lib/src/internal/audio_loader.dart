
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:web/web.dart';

import '../errors.dart';

class AudioLoader {
  static final List<String> supportedTypes = _getSupportedTypes();

  final HTMLAudioElement audio = HTMLAudioElement();
  final AggregateError aggregateError = AggregateError('Error loading sound.');
  final Completer<HTMLAudioElement> _completer = Completer<HTMLAudioElement>();

  late StreamSubscription<Event> _onCanPlaySubscription;
  late StreamSubscription<Event> _onErrorSubscription;
  final List<String> _urls = <String>[];
  bool _loadData = false;

  AudioLoader(List<String> urls, bool loadData, bool corsEnabled) {
    // we have to add the AudioElement to the document,
    // otherwise some browser won't start loading :(

    document.body!.appendChild(audio);

    if (corsEnabled) audio.crossOrigin = 'anonymous';

    _urls.addAll(urls);
    _loadData = loadData;
    _onCanPlaySubscription = audio.onCanPlay.listen(_onAudioCanPlay);
    _onErrorSubscription = audio.onError.listen(_onAudioError);
    _loadNextUrl();
  }

  Future<HTMLAudioElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onAudioCanPlay(Event event) {
    _onCanPlaySubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(audio);
  }

  void _onAudioError(Event event) {
    final ae = event.target as HTMLAudioElement;
    final loadError = LoadError('Failed to load ${ae.src}.', ae.error);
    aggregateError.errors.add(loadError);
    _loadNextUrl();
  }

  void _loadNextUrl() {
    if (_urls.isEmpty) {
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
    if (aggregateError.errors.isEmpty) {
      final loadError = LoadError('No configured audio type is supported.');
      aggregateError.errors.add(loadError);
    }
    _completer.completeError(aggregateError);
  }


  void _loadAudioData(String url) {
    http.get(Uri.parse(url)).then((request) {
      final url = Uri.dataFromBytes(request.bodyBytes);
      _loadAudioSource(url.toString());
    }).catchError((Object error) {
      final loadError = LoadError('Failed to load $url.', error);
      aggregateError.errors.add(loadError);
      _loadNextUrl();
    });
  }
  void _loadAudioSource(String url) {
    audio.preload = 'auto';
    audio.src = url;
    audio.load();
  }

  //-------------------------------------------------------------------------------------------------

  static List<String> _getSupportedTypes() {
    final supportedTypes = <String>[];
    final audio = HTMLAudioElement();
    final valid = ['maybe', 'probably'];

    if (valid.contains(audio.canPlayType('audio/ogg; codecs=opus'))) {
      supportedTypes.add('opus');
    }
    if (valid.contains(audio.canPlayType('audio/mpeg'))) {
      supportedTypes.add('mp3');
    }
    if (valid.contains(audio.canPlayType('audio/mp4'))) {
      supportedTypes.add('mp4');
    }
    if (valid.contains(audio.canPlayType('audio/ogg'))) {
      supportedTypes.add('ogg');
    }
    if (valid.contains(audio.canPlayType('audio/ac3'))) {
      supportedTypes.add('ac3');
    }
    if (valid.contains(audio.canPlayType('audio/wav'))) {
      supportedTypes.add('wav');
    }

    print('StageXL audio types   : $supportedTypes');

    return supportedTypes.toList(growable: false);
  }
}
