library stagexl.internal.environment;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'dart:typed_data';

final bool autoHiDPI = _checkAutoHiDPI();
final num devicePixelRatio = _checkDevicePixelRatio();
final Future<bool> isWebpSupported = _checkWebpSupport();
final bool isMobileDevice = _checkMobileDevice();
final bool isCocoonJS = _checkCocoonJS();
final bool isLittleEndianSystem = _checkLittleEndianSystem();

//-------------------------------------------------------------------------------------

num _checkDevicePixelRatio() {
  var devicePixelRatio = window.devicePixelRatio;
  if (devicePixelRatio is! num) devicePixelRatio = 1.0;
  return devicePixelRatio;
}

//-------------------------------------------------------------------------------------

bool _checkMobileDevice() {
  var ua = window.navigator.userAgent.toLowerCase();
  var identifiers = ["iphone", "ipad", "ipod", "android", "webos", "windows phone"];
  return identifiers.any((id) => ua.indexOf(id) >= 0);
}

//-------------------------------------------------------------------------------------

bool _checkCocoonJS() {
  return context["navigator"]["isCocoonJS"] == true;
}

//-------------------------------------------------------------------------------------

bool _checkLittleEndianSystem() {
  var wordList = new Int32List(1);
  var byteList = wordList.buffer.asUint8List();
  wordList[0] = 0x11223344;
  return byteList[0] == 0x44;
}

//-------------------------------------------------------------------------------------

bool _checkAutoHiDPI() {

  var autoHiDPI = devicePixelRatio > 1.0;
  var screen = window.screen;

  // only recent devices (> iPhone4) and hi-dpi desktops

  if (isMobileDevice && !isCocoonJS && screen != null) {
    autoHiDPI = autoHiDPI && (screen.width > 480 || screen.height > 480);
  }

  return autoHiDPI;
}

//-------------------------------------------------------------------------------------

Future<bool> _checkWebpSupport() {

  var completer = new Completer<bool>();
  var img = new ImageElement();

  img.onLoad.listen((e) => completer.complete(img.width == 2 && img.height == 2));
  img.onError.listen((e) => completer.complete(false));

  img.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAg'
      'CdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';

  return completer.future;
}
