library stagexl.internal.tools;

int colorGetA(int color) => (color >> 24) & 0xFF;
int colorGetR(int color) => (color >> 16) & 0xFF;
int colorGetG(int color) => (color >> 8) & 0xFF;
int colorGetB(int color) => color & 0xFF;

String color2rgb(int color) {
  final r = colorGetR(color);
  final g = colorGetG(color);
  final b = colorGetB(color);
  return 'rgb($r,$g,$b)';
}

String color2rgba(int color) {
  final r = colorGetR(color);
  final g = colorGetG(color);
  final b = colorGetB(color);
  final num a = colorGetA(color) / 255.0;
  return 'rgba($r,$g,$b,$a)';
}

//-----------------------------------------------------------------------------

bool similar(num a, num b, [num epsilon = 0.0001]) =>
    (a - epsilon < b) && (a + epsilon > b);

//-----------------------------------------------------------------------------

String getFilenameWithoutExtension(String filename) {
  final regex = RegExp(r'(.+?)(\.[^.]*$|$)');
  final match = regex.firstMatch(filename)!;
  return match.group(1)!;
}

//-----------------------------------------------------------------------------

String replaceFilename(String url, String filename) {
  final regex = RegExp(r'^(.*/)?(?:$|(.+?)(?:(\.[^.]*$)|$))');
  final match = regex.firstMatch(url)!;
  final path = match.group(1);
  return (path == null) ? filename : '$path$filename';
}
