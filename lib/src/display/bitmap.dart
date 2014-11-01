part of stagexl.display;

class Bitmap extends DisplayObject {

  BitmapData bitmapData;

  Bitmap([this.bitmapData = null]);

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return bitmapData == null
      ? new Rectangle<num>(0.0, 0.0, 0.0 ,0.0)
      : new Rectangle<num>(0.0, 0.0, bitmapData.width, bitmapData.height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    // We override the hitTestInput method for optimal performance.
    if (bitmapData == null) return null;
    if (localX < 0.0 || localX >= bitmapData.width) return null;
    if (localY < 0.0 || localY >= bitmapData.height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    if (bitmapData != null) bitmapData.render(renderState);
  }

}
