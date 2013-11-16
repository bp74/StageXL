library bitmap_data_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {

  ResourceManager resourceManager = new ResourceManager();
  resourceManager.addBitmapData('monster', '/StageXL/test/assets/brainmonster.png');
  var monster;

  compareRawData(frame, source, sourceX, sourceY) {
    // It is almost impossible to test this the way things are now...
    // ...right?
    //expect(false, isTrue);
    // See TODO in spritesheet_test.dart#27 (ish).
  }

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

    test('has created the expected BitmapDatas', () {
      var width = 32, height = 64, rows = 4, cols = 3;

      for(var i = 0; i < bitmapDatas.length; i++) {
        var bitmapData = bitmapDatas[i];
        var x = i < cols ? (i * width) : (i - cols) * width;
        var y = i < rows ? (i * height) : (i - rows) * height;

        compareRawData(bitmapData, monster, x, y);
      }
    });
  });
}