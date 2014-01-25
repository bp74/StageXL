part of stagexl;

class Bitmap extends DisplayObject {

  BitmapData bitmapData;
  Rectangle clipRectangle = null;

  Bitmap([this.bitmapData = null]);

  //-------------------------------------------------------------------------------------------------

  Rectangle getBoundsTransformed(Matrix matrix, [Rectangle returnRectangle]) {
    var width = bitmapData != null ? bitmapData.width : 0;
    var height = bitmapData != null ? bitmapData.height : 0;
    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  DisplayObject hitTestInput(num localX, num localY) {
    return bitmapData != null &&
        localX >= 0.0 && localY >= 0.0 &&
        localX < bitmapData.width && localY < bitmapData.height ? this : null;
  }

  void render(RenderState renderState) {
    if (bitmapData != null) {
      if (clipRectangle == null) {
        bitmapData.render(renderState);
      } else {
        bitmapData.renderClipped(renderState, clipRectangle);
      }
    }
  }

}
