import 'dart:async';
import 'dart:js_interop';

import 'package:http/http.dart' as http;
import 'package:web/web.dart';

import '../../stagexl.dart';
import 'environment.dart' as env;

class ImageBitmapLoader {
  final String _url;
  final _completer = Completer<ImageBitmap>();
  bool _cancelled = false;

  ImageBitmapLoader(String url, bool webpAvailable) : _url = url {
    if (webpAvailable) {
      env.isWebpSupported.then(_onWebpSupported);
    } else {
      _load(url);
    }
  }

  void _load(String url) {
    http.get(Uri.parse(url)).then((response) {
      if (_cancelled) {
        _completer.completeError(LoadError('image bitmap load cancelled'));
        return;
      }
      if (response.statusCode == 200) {
        try {
          final imageBitmap = window.createImageBitmap(Blob([response.bodyBytes.toJS].toJS)).toDart;
          _completer.complete(imageBitmap);
        } catch (e) {
          _completer.completeError(e);
        }
      }
    });
  }

  void cancel() => _cancelled = true;

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
