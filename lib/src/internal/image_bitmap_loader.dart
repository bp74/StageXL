library stagexl.internal.image_bitmap_loader;

import 'dart:async';
import 'dart:html';
import 'dart:js_util';

import 'package:stagexl/src/engine.dart';

import 'image_asset_loader.dart';
import 'environment.dart' as env;
import '../display.dart';

class ImageBitmapLoader extends ImageAssetLoader {
  final String _url;
  final _completer = Completer<ImageBitmap>();
  HttpRequest? _request;
  ImageBitmap? imageBitmap;

  ImageBitmapLoader(String url, bool webpAvailable, {num pixelRatio = 1.0}) : _url = url, super(pixelRatio)  {
    if (webpAvailable) {
      env.isWebpSupported.then(_onWebpSupported);
    } else {
      _load(url);
    }
  }

  void _load(String url) {
    final request = _request = HttpRequest();
    request
      ..onProgress.listen(updateProgress)
      ..onReadyStateChange.listen((_) async {
        if (request.readyState == HttpRequest.DONE && request.status == 200) {
          try {
            final blob = request.response as Blob;

            // Note: Dart SDK does not support createImageBitmap, so
            // use callMethod and convert from promise to future.
            // See https://github.com/dart-lang/sdk/issues/12379
            final promise = callMethod(window, 'createImageBitmap', [blob]);
            imageBitmap =
              await promiseToFuture<ImageBitmap>(promise as Object);

            _completer.complete(imageBitmap);
          } catch (e) {
            _completer.completeError(e);
          }
        }
      })
      ..onError.listen(_completer.completeError)
      ..open('GET', url, async: true)
      ..responseType = 'blob'
      ..send();
  }
  void updateProgress(ProgressEvent progressEvent) {
    if (progressEvent.lengthComputable)
    {
      progress = (progressEvent.loaded ?? 0) / (progressEvent.total ?? 1) * 100;
    }
  }

  @override
  void cancel() => _request?.abort();

  @override
  BitmapData getBitmapData() => BitmapData.fromImageBitmap(imageBitmap!, pixelRatio);

  @override
  RenderTextureQuad getRenderTextureQuad() {
    final renderTexture = RenderTexture.fromImageBitmap(imageBitmap!);
    return renderTexture.quad.withPixelRatio(pixelRatio);
  }

  //---------------------------------------------------------------------------

  @override
  Future<ImageBitmap> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onWebpSupported(bool webpSupported) {
    var match = RegExp(r'(png|jpg|jpeg)$').firstMatch(_url);
    if (webpSupported && match != null) {
      _load(_url);
    }
  }


}
