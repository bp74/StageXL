library bitmap_data_test;

import 'package:unittest/unittest.dart';
import 'package:stagexl/stagexl.dart';

void main() {

  ResourceManager resourceManager = new ResourceManager();
  BitmapData monster;
  List<BitmapData> bitmapDatas;

  resourceManager.addBitmapData('monster', 'common/images/brainmonster.png');

  setUp(() {
    return resourceManager.load().then((_) {
      monster = resourceManager.getBitmapData('monster');
      bitmapDatas = monster.sliceIntoFrames(32, 64);
    });
  });

  group('sliceSpriteSheet', () {

    test('creates the expected number of BitmapDatas', () {
      expect(bitmapDatas.length, equals(12));
    });

    test('optionally only parses the number of tiles specified by frameCount', () {
    bitmapDatas = monster.sliceIntoFrames(32, 64, frameCount: 1);
      expect(bitmapDatas.length, equals(1));
    });

    test('has created the expected BitmapDatas', () {
      for (var index = 0; index < bitmapDatas.length; index++) {
        var x = index % 3;
        var y = index ~/ 3;
        var id1 = bitmapDatas[index].renderTextureQuad.getImageData();
        var id2 = monster.renderTexture.canvas.context2D.getImageData(x * 32, y * 64, 32, 64);
        expect(id1.data, equals(id2.data), reason: "@frame $index");
      }
    });
  });
}
