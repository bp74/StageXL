@TestOn('browser')
library image_bitmap_test;

import 'dart:html' show ImageBitmap;
import 'dart:math' show pi;

import 'package:stagexl/stagexl.dart';
import 'package:test/test.dart';

void main() {
  late BitmapData spiders;

  setUp(() async {
    StageXL.bitmapDataLoadOptions.imageBitmap = true;

    final resourceManager = ResourceManager();
    resourceManager.addBitmapData('spiders', '../common/images/spider.png');
    await resourceManager.load();
    spiders = resourceManager.getBitmapData('spiders');
  });

  //---------------------------------------------------------------------------

  test('render texture is an ImageBitmap', () {
    final image = spiders.renderTexture.imageBitmap;
    expect(image is ImageBitmap, true);
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
