part of stagexl;

class GlassPlate extends InteractiveObject {

  num width;
  num height;

  GlassPlate(this.width, this.height);

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle<num> getBoundsTransformed(Matrix matrix, [Rectangle<num> returnRectangle]) {
    return _getBoundsTransformedHelper(matrix, width, height, returnRectangle);
  }

  //-------------------------------------------------------------------------------------------------

  DisplayObject hitTestInput(num localX, num localY) {
    return localX >= 0.0 && localY >= 0.0  && localX < width && localY < height ? this : null;
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

  }

}
