@TestOn('browser')
library bitmap_data_test;

import 'package:test/test.dart';
import 'package:stagexl/stagexl.dart';

void main() {
  ResourceManager? resourceManager;
  List<BitmapData>? bitmapDatas;
  BitmapData? monster;

  setUp(() async {
    resourceManager = ResourceManager();
    resourceManager!
        .addBitmapData('monster', '../common/images/brainmonster.png');
    await resourceManager!.load();
    monster = resourceManager!.getBitmapData('monster');
    bitmapDatas = monster!.sliceIntoFrames(32, 64);
  });

  tearDown(() {
    resourceManager = null;
    bitmapDatas = null;
    monster = null;
  });

  //---------------------------------------------------------------------------

  group('sliceSpriteSheet', () {
    test('creates the expected number of BitmapDatas', () {
      expect(bitmapDatas!.length, equals(12));
    });

    test('optionally only parses the number of tiles specified by frameCount',
        () {
      bitmapDatas = monster!.sliceIntoFrames(32, 64, frameCount: 1);
      expect(bitmapDatas!.length, equals(1));
    });

    test('has created the expected BitmapDatas', () {
      for (var index = 0; index < bitmapDatas!.length; index++) {
        final x = index % 3;
        final y = index ~/ 3;
        final id1 = bitmapDatas![index].renderTextureQuad.getImageData();
        final id2 = monster!.renderTexture.canvas.context2D
            .getImageData(x * 32, y * 64, 32, 64);
        expect(id1.data, equals(id2.data), reason: '@frame $index');
      }
    });
  });
}
