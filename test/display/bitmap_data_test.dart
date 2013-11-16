library bitmap_data_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('spiders', '/StageXL/test/assets/spider.png');
  var spiders;

  setUp(() {
    return resourceManager.load().then((_) {
      spiders = resourceManager.getBitmapData('spiders');
    });
  });
}