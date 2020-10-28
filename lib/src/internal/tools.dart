library stagexl.internal.tools;

int colorGetA(int color) => (color >> 24) & 0xFF;
int colorGetR(int color) => (color >> 16) & 0xFF;
int colorGetG(int color) => (color >> 8) & 0xFF;
int colorGetB(int color) => (color) & 0xFF;

String color2rgb(int color) {
  var r = colorGetR(color);
  var g = colorGetG(color);
  var b = colorGetB(color);
  return 'rgb($r,$g,$b)';
}

String color2rgba(int color) {
  var r = colorGetR(color);
  var g = colorGetG(color);
  var b = colorGetB(color);
  num a = colorGetA(color) / 255.0;
  return 'rgba($r,$g,$b,$a)';
}

//-----------------------------------------------------------------------------

bool similar(num a, num b, [num epsilon = 0.0001]) {
  return (a - epsilon < b) && (a + epsilon > b);
}

//-----------------------------------------------------------------------------

String getFilenameWithoutExtension(String filename) {
  var regex = RegExp(r'(.+?)(\.[^.]*$|$)');
  var match = regex.firstMatch(filename)!;
  return match.group(1)!;
}

//-----------------------------------------------------------------------------

String? replaceFilename(String url, String? filename) {
  var regex = RegExp(r'^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))');
  var match = regex.firstMatch(url)!;
  var path = match.group(1);
  return (path == null) ? filename : '$path$filename';
}
