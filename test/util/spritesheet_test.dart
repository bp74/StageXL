@TestOn('browser')
library;

import 'package:stagexl/stagexl.dart';
import 'package:test/test.dart';
import 'package:web/web.dart';

void main() {
  late ResourceManager resourceManager;
  late SpriteSheet spritesheet;
  late BitmapData spiders;

  setUp(() async {
    resourceManager = ResourceManager();
    resourceManager.addBitmapData('spiders', '../common/images/spider.png');
    await resourceManager.load();
    spiders = resourceManager.getBitmapData('spiders');
    spritesheet = SpriteSheet(spiders, 32, 32);
  });

  //---------------------------------------------------------------------------

  test('SpriteSheet assigns source BitmapData', () {
    expect(spritesheet.source, equals(spiders));
  });

  test('SpriteSheet.frames is the expected size', () {
    expect(spritesheet.frames.length, equals(28));
  });

  test('SpriteSheet.frames calls BitmapData.sliceSpriteSheet correctly', () {
    for (var index = 0; index < spritesheet.frames.length; index++) {
      final x = index % 7;
      final y = index ~/ 7;
      final id1 = spritesheet.frames[index].renderTextureQuad.getImageData();
      final id2 = spiders.renderTexture.canvas.context2D
          .getImageData(x * 32, y * 32, 32, 32);
      expect(id1.data, equals(id2.data), reason: '@frame $index');
    }
  });

  test('SpriteSheet.frameAt uses SpriteSheet.frames', () {
    for (var index = 0; index < spritesheet.frames.length; index++) {
      expect(spritesheet.frameAt(index), equals(spritesheet.frames[index]));
    }
  });
}
