library stagexl.util.image_loader;

import 'dart:async';
import 'dart:html' as html;

import 'dart:html' show
  Element, ImageElement, AudioElement, HttpRequest,
  CanvasElement, CanvasRenderingContext2D, CanvasImageSource,
  CanvasPattern, CanvasGradient, ImageData;

import 'tools.dart';

class ImageLoader {

  final ImageElement _image = new ImageElement();
  final Completer<ImageElement> _completer = new Completer<ImageElement>();

  String _url;
  StreamSubscription _onLoadSubscription;
  StreamSubscription _onErrorSubscription;

  ImageLoader(String url, bool webpAvailable, bool corsEnabled) {

    _url = url;
    _onLoadSubscription = _image.onLoad.listen(_onImageLoad);
    _onErrorSubscription = _image.onError.listen(_onImageError);

    if (corsEnabled) {
      _image.crossOrigin = 'anonymous';
    }

    if (webpAvailable) {
      isWebpSupported.then(_onWebpSupported);
    } else {
      _image.src = _url;
    }
  }

  //---------------------------------------------------------------------------

  Future<ImageElement> get done => _completer.future;
  ImageElement get image => _image;

  //---------------------------------------------------------------------------

  void _onWebpSupported(bool webpSupported) {
    var match = new RegExp(r"(png|jpg|jpeg)$").firstMatch(_url);
    if (webpSupported && match != null) {
      _image.src = _url.substring(0, match.start) + "webp";
    } else {
      _image.src = _url;
    }
  }

  void _onImageLoad(html.Event event) {
    _onLoadSubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.complete(image);
  }

  void _onImageError(html.Event event) {
    _onLoadSubscription.cancel();
    _onErrorSubscription.cancel();
    _completer.completeError(new StateError("Failed to load image."));
  }
}
