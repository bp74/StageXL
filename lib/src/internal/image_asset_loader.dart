import '../display.dart';
import '../engine.dart';
import '../resources.dart';
abstract class ImageAssetLoader {
  num pixelRatio;
  num? progress;
  BitmapData? bitmapData;

  ImageAssetLoader (this.pixelRatio);

  TextureAtlas? textureAtlas;

  BitmapData getBitmapData();
  RenderTexture getRenderTexture();

  void cancel();
  num? getProgress() => progress;
  Future get done;
}
