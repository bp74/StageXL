import 'dart:async';
import 'dart:html';
import 'dart:js_util';

import 'environment.dart' as env;

class ImageBitmapLoader {
  final String _url;
  final _completer = Completer<ImageBitmap>();
  HttpRequest? _request;

  ImageBitmapLoader(String url, bool webpAvailable) : _url = url {
    if (webpAvailable) {
      env.isWebpSupported.then(_onWebpSupported);
    } else {
      _load(url);
    }
  }

  void _load(String url) {
    final request = _request = HttpRequest();
    request
      ..onReadyStateChange.listen((_) async {
        if (request.readyState == HttpRequest.DONE && request.status == 200) {
          try {
            final blob = request.response as Blob;

            // Note: Dart SDK does not support createImageBitmap, so
            // use callMethod and convert from promise to future.
            // See https://github.com/dart-lang/sdk/issues/12379
            final promise =
                callMethod<Object>(window, 'createImageBitmap', [blob]);
            final imageBitmap = await promiseToFuture<ImageBitmap>(promise);

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

  void cancel() => _request?.abort();

  //---------------------------------------------------------------------------

  Future<ImageBitmap> get done => _completer.future;

  //---------------------------------------------------------------------------

  void _onWebpSupported(bool webpSupported) {
    var match = RegExp(r'(png|jpg|jpeg)$').firstMatch(_url);
    if (webpSupported && match != null) {
      _load(_url);
    }
  }
}
