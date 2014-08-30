library stagexl.internal.tools;

import '../geom/matrix.dart';
import '../geom/rectangle.dart';

//-----------------------------------------------------------------------------

int colorGetA(int color) => (color >> 24) & 0xFF;
int colorGetR(int color) => (color >> 16) & 0xFF;
int colorGetG(int color) => (color >>  8) & 0xFF;
int colorGetB(int color) => (color      ) & 0xFF;

String color2rgb(int color) {
  int r = colorGetR(color);
  int g = colorGetG(color);
  int b = colorGetB(color);
  return "rgb($r,$g,$b)";
}

String color2rgba(int color) {
  int r = colorGetR(color);
  int g = colorGetG(color);
  int b = colorGetB(color);
  num a = colorGetA(color) / 255.0;
  return "rgba($r,$g,$b,$a)";
}

//-----------------------------------------------------------------------------

bool ensureBool(bool value) {
  if (value is bool) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a bool.");
  }
}

int ensureInt(int value) {
  if (value is int) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not an int.");
  }
}

num ensureNum(num value) {
  if (value is num) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a number.");
  }
}

String ensureString(String value) {
  if (value is String) {
    return value;
  } else {
    throw new ArgumentError("The supplied value ($value) is not a string.");
  }
}

//-----------------------------------------------------------------------------

String getFilenameWithoutExtension(String filename) {
  RegExp regex = new RegExp(r"(.+?)(\.[^.]*$|$)");
  Match match = regex.firstMatch(filename);
  return match.group(1);
}

//-----------------------------------------------------------------------------

String replaceFilename(String url, String filename) {
  RegExp regex = new RegExp(r"^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))");
  Match match = regex.firstMatch(url);
  String path = match.group(1);
  return (path == null) ? filename : "$path$filename";
}

//-----------------------------------------------------------------------------

Rectangle<num> getBoundsTransformedHelper(
    Matrix matrix, num width, num height, Rectangle<num> returnRectangle) {

  width = width.toDouble();
  height = height.toDouble();

  // tranformedX = X * matrix.a + Y * matrix.c + matrix.tx;
  // tranformedY = X * matrix.b + Y * matrix.d + matrix.ty;

  num x1 = matrix.tx;
  num y1 = matrix.ty;
  num x2 = matrix.tx + width * matrix.a;
  num y2 = matrix.ty + width * matrix.b;
  num x3 = matrix.tx + width * matrix.a + height * matrix.c;
  num y3 = matrix.ty + width * matrix.b + height * matrix.d;
  num x4 = matrix.tx + height * matrix.c;
  num y4 = matrix.ty + height * matrix.d;

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

  if (returnRectangle == null) {
    returnRectangle = new Rectangle<num>(left, top, right - left, bottom - top);
  } else {
    returnRectangle.setTo(left, top, right - left, bottom - top);
  }

  return returnRectangle;
}
