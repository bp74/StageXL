library stagexl.internal.image_loader;

import 'dart:async';
import 'dart:html';

import '../errors.dart';
import 'environment.dart' as env;

class ImageLoader {
  final ImageElement image = ImageElement();
  final Completer<ImageElement> _completer = Completer<ImageElement>();

  final String _url;
  late StreamSubscription<Event> _onLoadSubscription;
  late StreamSubscription<Event> _onErrorSubscription;

  ImageLoader(String url, bool webpAvailable, bool corsEnabled) : _url = url {
    _onLoadSubscription = image.onLoad.listen(_onImageLoad);
    _onErrorSubscription = image.onError.listen(_onImageError);

    if (corsEnabled) {
      image.crossOrigin = 'anonymous';
    }

    if (webpAvailable) {
      env.isWebpSupported.then(_onWebpSupported);
    } else {
      image.src = _url;
    }
  }

  //---------------------------------------------------------------------------

  Future<ImageElement> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onWebpSupported(bool webpSupported) {
    final match = RegExp(r'(png|jpg|jpeg)$').firstMatch(_url);
    if (webpSupported && match != null) {
      image.src = '${_url.substring(0, match.start)}webp';
    } else {
      image.src = _url;
    }
  }

  void _onImageLoad(Event event) {
    _onLoadSubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(image);
  }

  void _onImageError(Event event) {
    _onLoadSubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.completeError(LoadError('Failed to load ${image.src}.'));
  }
}
