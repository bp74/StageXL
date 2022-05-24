import '../display.dart';
import '../engine.dart';
abstract class ImageAssetLoader {
  num pixelRatio;
  num? progress;

  ImageAssetLoader (this.pixelRatio);

  BitmapData getBitmapData();
  RenderTextureQuad getRenderTextureQuad();

  void cancel();
  num? getProgress() => progress;
  Future get done;
}
