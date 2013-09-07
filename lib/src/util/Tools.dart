part of stagexl;

//-------------------------------------------------------------------------------------------------

String _color2rgb(int color) {

  int r = (color >> 16) & 0xFF;
  int g = (color >>  8) & 0xFF;
  int b = (color >>  0) & 0xFF;

  return "rgb($r,$g,$b)";
}

String _color2rgba(int color) {

  int a = (color >> 24) & 0xFF;
  int r = (color >> 16) & 0xFF;
  int g = (color >>  8) & 0xFF;
  int b = (color >>  0) & 0xFF;

  return "rgba($r,$g,$b,${a / 255.0})";
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

bool _checkLittleEndianSystem() {

  var canvas = new CanvasElement(width: 1, height: 1);
  canvas.context2D.fillStyle = "#000000";
  canvas.context2D.fillRect(0, 0, 1, 1);

  var data = canvas.context2D.getImageData(0, 0, 1, 1).data;
  var littleEndian = (data[0] == 0);

  return littleEndian;
}

//-------------------------------------------------------------------------------------------------

Future<bool> _checkWebpSupport() {

  var completer = new Completer<bool>();
  var image = new ImageElement();

  void checkImage() {
    completer.complete(image.width == 2 && image.height == 2);
  }

  image.onLoad.listen((e) => checkImage());
  image.onError.listen((e) => checkImage());
  image.src = "data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA";

  return completer.future;
}

//-------------------------------------------------------------------------------------------------

Rectangle _getBoundsTransformedHelper(Matrix matrix, num width, num height, Rectangle returnRectangle) {

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

  if (returnRectangle == null)
    returnRectangle = new Rectangle.zero();

  returnRectangle.x = matrix.tx + left;
  returnRectangle.y = matrix.ty + top;
  returnRectangle.width = right - left;
  returnRectangle.height = bottom - top;

  return returnRectangle;
}

//------------------------------------------------------------------------------------------------------

