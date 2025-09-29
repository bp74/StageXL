@TestOn('browser')
library;

import 'dart:math' show pi;

import 'package:stagexl/stagexl.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  late BitmapData spiders;

  setUp(() async {
    final resourceManager = ResourceManager();
    resourceManager.addBitmapData('spiders', '../common/images/spider.png');
    await resourceManager.load();
    spiders = resourceManager.getBitmapData('spiders');
  });

  //---------------------------------------------------------------------------

  test('render texture is an ImageBitmap', () {
    final image = spiders.renderTexture.imageBitmap;
    expect(image is web.ImageBitmap, StageXL.environment.isImageBitmapSupported);
  });

  test('getImageData works', () {
    final image = spiders.renderTexture.quad.getImageData();
    expect(image.width, equals(224));
    expect(image.height, equals(128));
  });

  test('rotation works', () {
    final image = Bitmap(spiders);
    image.rotation = toRadians(90);
    expect(image.width, equals(128));
  });
}

num toRadians(num degrees) => degrees * (pi / 180);
