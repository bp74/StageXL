library bitmap_data_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('monster', '/StageXL/test/assets/brainmonster.png');
  var monster;

  setUp(() {
    return resourceManager.load().then((_) {
      monster = resourceManager.getBitmapData('monster');
    });
  });
  
  group('sliceSpriteSheet', () {
    List<BitmapData> bitmapDatas;
    setUp(() => bitmapDatas = BitmapData.sliceSpriteSheet(monster, 32, 64));
    
    test('creates the expected number of BitmapDatas', () {
      expect(bitmapDatas.length, equals(12));      
    });
  });
}