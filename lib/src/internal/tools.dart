library stagexl.internal.tools;

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

int minInt(int a, int b) => a < b ? a : b;

int maxInt(int a, int b) => a > b ? a : b;

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
