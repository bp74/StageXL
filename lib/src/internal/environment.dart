library stagexl.internal.environment;

import 'dart:async';
import 'dart:html';
import 'dart:js';

class Environment {

  static final bool autoHiDPI = _checkAutoHiDPI();
  static final num devicePixelRatio = _checkDevicePixelRatio();
  static final Future<bool> isWebpSupported = _checkWebpSupport();
  static final bool isMobileDevice = _checkMobileDevice();
  static final bool isCocoonJS = _checkCocoonJS();

  //-------------------------------------------------------------------------------------

  static num _checkDevicePixelRatio() {
    var devicePixelRatio = window.devicePixelRatio;
    if (devicePixelRatio is! num) devicePixelRatio = 1.0;
    return devicePixelRatio;
  }

  //-------------------------------------------------------------------------------------

  static bool _checkMobileDevice() {
    var ua = window.navigator.userAgent.toLowerCase();
    var identifiers = ["iphone", "ipad", "ipod", "android", "webos", "windows phone"];
    return identifiers.any((id) => ua.indexOf(id) >= 0);
  }

  //-------------------------------------------------------------------------------------

  static bool _checkCocoonJS() {
    return context["navigator"]["isCocoonJS"] == true;
  }

  //-------------------------------------------------------------------------------------

  static bool _checkAutoHiDPI() {

    var autoHiDPI = devicePixelRatio > 1.0;
    var screen = window.screen;

    // only recent devices (> iPhone4) and hi-dpi desktops

    if (isMobileDevice && !isCocoonJS && screen != null) {
      var width = screen.width;
      var height = screen.height;
      if (width <= 480 || height <= 480) autoHiDPI = false;
    }

    return autoHiDPI;
  }

  //-------------------------------------------------------------------------------------

  static Future<bool> _checkWebpSupport() {

    var completer = new Completer<bool>();
    var img = new ImageElement();

    img.onLoad.listen((e) => completer.complete(img.width == 2 && img.height == 2));
    img.onError.listen((e) => completer.complete(false));

    img.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAg'
        'CdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';

    return completer.future;
  }


}








