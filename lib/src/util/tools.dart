part of stagexl;

//-------------------------------------------------------------------------------------------------

int _colorGetA(int color) => (color >> 24) & 0xFF;
int _colorGetR(int color) => (color >> 16) & 0xFF;
int _colorGetG(int color) => (color >>  8) & 0xFF;
int _colorGetB(int color) => (color      ) & 0xFF;

String _color2rgb(int color) {
  int r = _colorGetR(color);
  int g = _colorGetG(color);
  int b = _colorGetB(color);
  return "rgb($r,$g,$b)";
}

String _color2rgba(int color) {
  int r = _colorGetR(color);
  int g = _colorGetG(color);
  int b = _colorGetB(color);
  num a = _colorGetA(color) / 255.0;
  return "rgba($r,$g,$b,$a)";
}

//-------------------------------------------------------------------------------------------------

bool _ensureBool(bool value) {
  if (value is bool) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a bool.");
  }
}

int _ensureInt(int value) {
  if (value is int) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not an int.");
  }
}

num _ensureNum(num value) {
  if (value is num) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a number.");
  }
}

String _ensureString(String value) {
  if (value is String) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a string.");
  }
}

//-------------------------------------------------------------------------------------------------

String _getFilenameWithoutExtension(String filename) {

  RegExp regex = new RegExp(r"(.+?)(\.[^.]*$|$)", multiLine:false, caseSensitive:false);
  Match match = regex.firstMatch(filename);
  return match.group(1);
}

//-------------------------------------------------------------------------------------------------

String _replaceFilename(String url, String filename) {

  RegExp regex = new RegExp(r"^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))", multiLine:false, caseSensitive:false);
  Match match = regex.firstMatch(url);
  String path = match.group(1);
  return (path == null) ? filename : "$path$filename";
}

//-------------------------------------------------------------------------------------------------

Future<bool> _checkWebpSupport() {

  var webpUrl = "data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA";
  var loader = new _ImageLoader(webpUrl, false, false);

  return loader.done.then((ImageElement image) {
    return image.width == 2 && image.height == 2;
  }).catchError((e) {
    return false;
  });
}

bool _checkMobileDevice() {
  var ua = html.window.navigator.userAgent.toLowerCase();
  var identifiers = ["iphone", "ipad", "ipod", "android", "webos", "windows phone"];
  return identifiers.any((id) => ua.indexOf(id) >= 0);
}

bool _checkHiDpi() {
  var devicePixelRatio = _devicePixelRatio;
  var isMobileDevice = _isMobile;
  var isCocoonJS = _isCocoonJS;
  var screen = html.window.screen;
  var screenSize = screen is html.Screen ? max(screen.width, screen.height) : 1024;

  // only recent devices (> iPhone4) and hi-dpi desktops
  return devicePixelRatio > 1.0 && (isMobileDevice == false || screenSize > 480 || isCocoonJS);
}

bool _checkCocoonJS() {
  return context["navigator"]["isCocoonJS"] == true;
}

//-------------------------------------------------------------------------------------------------

Rectangle _getBoundsTransformedHelper(Matrix matrix, num width, num height,
                                      Rectangle<num> returnRectangle) {

  width = width.toDouble();
  height = height.toDouble();

  // tranformedX = X * matrix.a + Y * matrix.c + matrix.tx;
  // tranformedY = X * matrix.b + Y * matrix.d + matrix.ty;

  num x1 = 0.0;
  num y1 = 0.0;
  num x2 = width * matrix.a;
  num y2 = width * matrix.b;
  num x3 = width * matrix.a + height * matrix.c;
  num y3 = width * matrix.b + height * matrix.d;
  num x4 = height * matrix.c;
  num y4 = height * matrix.d;

  num left = x1;
  if (left > x2) left = x2;
  if (left > x3) left = x3;
  if (left > x4) left = x4;

  num top = y1;
  if (top > y2 ) top = y2;
  if (top > y3 ) top = y3;
  if (top > y4 ) top = y4;

  num right = x1;
  if (right < x2) right = x2;
  if (right < x3) right = x3;
  if (right < x4) right = x4;

  num bottom = y1;
  if (bottom < y2 ) bottom = y2;
  if (bottom < y3 ) bottom = y3;
  if (bottom < y4 ) bottom = y4;

  if (returnRectangle != null) {
    returnRectangle.setTo(
        matrix.tx + left, matrix.ty + top, right - left, bottom - top);
  } else {
    returnRectangle = new Rectangle<num>(
        matrix.tx + left, matrix.ty + top, right - left, bottom - top);
  }

  return returnRectangle;
}
