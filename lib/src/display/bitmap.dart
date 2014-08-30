part of stagexl.display;

class Bitmap extends DisplayObject {

  BitmapData bitmapData;

  Bitmap([this.bitmapData = null]);

  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {
    var width = bitmapData != null ? bitmapData.width : 0;
    var height = bitmapData != null ? bitmapData.height : 0;
    return getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  DisplayObject hitTestInput(num localX, num localY) {
    return bitmapData != null &&
        localX >= 0.0 && localY >= 0.0 &&
        localX < bitmapData.width && localY < bitmapData.height ? this : null;
  }

  void render(RenderState renderState) {
    if (bitmapData != null) bitmapData.render(renderState);
  }

}
