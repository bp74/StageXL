library spritesheet_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';
import 'dart:async';

void main() {
  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('spiders', '/StageXL/test/assets/spider.png');
  resourceManager.load().then((_) {
    
    var spiders = resourceManager.getBitmapData('spiders');
    var spritesheet = new SpriteSheet(spiders);
    
    test('SpriteSheet assigns source BitmapData', () {
      expect(spritesheet.source, equals(spiders));
    });
    
  });
}