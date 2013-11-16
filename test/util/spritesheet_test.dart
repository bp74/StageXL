library spritesheet_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';
import 'dart:async';

void main() {
  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('spiders', '/StageXL/test/assets/spider.png');
  var spiders, spritesheet;

  setUp(() {
    return resourceManager.load().then((_) {
      spiders = resourceManager.getBitmapData('spiders');
      spritesheet = new SpriteSheet(spiders);
    });
  });

  test('SpriteSheet assigns source BitmapData', () {
    expect(spritesheet.source, equals(spiders));
  });
}