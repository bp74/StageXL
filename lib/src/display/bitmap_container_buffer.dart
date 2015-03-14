part of stagexl.display;

class _BitmapContainerBuffer extends RenderBufferVertex {

  final _BitmapContainerProgram program;
  final BitmapProperty bitmapProperty;
  final int quads;
  final int stride;

  final bool _useBitmapBitmapData;
  final bool _useBitmapPosition;
  final bool _useBitmapPivot;
  final bool _useBitmapScale;
  final bool _useBitmapSkew;
  final bool _useBitmapRotation;
  final bool _useBitmapAlpha;
  final bool _useBitmapVisible;

  _BitmapContainerBuffer(_BitmapContainerProgram program,
                         BitmapProperty bitmapProperty,
                         int quads, int stride) : super(quads * 4 * stride),

    this.program = program,
    this.bitmapProperty = bitmapProperty,
    this.quads = quads,
    this.stride = stride,

    _useBitmapBitmapData = program.bitmapBitmapData == bitmapProperty,
    _useBitmapPosition = program.bitmapPosition == bitmapProperty,
    _useBitmapPivot = program.bitmapPivot == bitmapProperty,
    _useBitmapScale = program.bitmapScale == bitmapProperty,
    _useBitmapSkew = program.bitmapSkew == bitmapProperty,
    _useBitmapRotation = program.bitmapRotation == bitmapProperty,
    _useBitmapAlpha = program.bitmapAlpha == bitmapProperty,
    _useBitmapVisible = program.bitmapVisible == bitmapProperty;

  //---------------------------------------------------------------------------

  void bindAttributes() {

    int offset = 0;
    int stride = 4 * this.stride;

    if (_useBitmapBitmapData) {
      var aBitmapData = program.attributes["aBitmapData"];
      this.bindAttribute(aBitmapData, 4, stride, offset);
      offset += 16;
    }

    if (_useBitmapPosition) {
      var aPosition = program.attributes["aPosition"];
      this.bindAttribute(aPosition, 2, stride, offset);
      offset += 8;
    }

    if (_useBitmapPivot) {
      var aPivot = program.attributes["aPivot"];
      this.bindAttribute(aPivot, 2, stride, offset);
      offset += 8;
    }

    if (_useBitmapScale) {
      var aScale = program.attributes["aScale"];
      this.bindAttribute(aScale, 2, stride, offset);
      offset += 8;
    }

    if (_useBitmapSkew) {
      var aSkew = program.attributes["aSkew"];
      this.bindAttribute(aSkew, 2, stride, offset);
      offset += 8;
    }

    if (_useBitmapRotation) {
      var aRotation = program.attributes["aRotation"];
      this.bindAttribute(aRotation, 1, stride, offset);
      offset += 4;
    }

    if (_useBitmapAlpha) {
      var aAlpha = program.attributes["aAlpha"];
      this.bindAttribute(aAlpha, 1, stride, offset);
      offset += 4;
    }
  }

  //---------------------------------------------------------------------------

  void setVertexData(Bitmap bitmap, int quadIndex) {

    var vertex0 = stride * 0;
    var vertex1 = stride * 1;
    var vertex2 = stride * 2;
    var vertex3 = stride * 3;
    var offset  = stride * 4 * quadIndex;

    if (_useBitmapBitmapData) {
      var renderTextureQuad = bitmap.bitmapData.renderTextureQuad;
      var quadX = renderTextureQuad.offsetX.toDouble();
      var quadY = renderTextureQuad.offsetY.toDouble();
      var quadWidth = renderTextureQuad.textureWidth.toDouble();
      var quadHeight = renderTextureQuad.textureHeight.toDouble();
      var quadUVs = renderTextureQuad.uvList;
      data[offset + vertex0 + 0] = quadX;
      data[offset + vertex0 + 1] = quadY;
      data[offset + vertex0 + 2] = quadUVs[0];
      data[offset + vertex0 + 3] = quadUVs[1];
      data[offset + vertex1 + 0] = quadX + quadWidth;
      data[offset + vertex1 + 1] = quadY;
      data[offset + vertex1 + 2] = quadUVs[2];
      data[offset + vertex1 + 3] = quadUVs[3];
      data[offset + vertex2 + 0] = quadX + quadWidth;
      data[offset + vertex2 + 1] = quadY + quadHeight;
      data[offset + vertex2 + 2] = quadUVs[4];
      data[offset + vertex2 + 3] = quadUVs[5];
      data[offset + vertex3 + 0] = quadX;
      data[offset + vertex3 + 1] = quadY + quadHeight;
      data[offset + vertex3 + 2] = quadUVs[6];
      data[offset + vertex3 + 3] = quadUVs[7];
      offset += 4;
    }

    if (_useBitmapPosition) {
      var x = bitmap.x.toDouble();
      var y = bitmap.y.toDouble();
      data[offset + vertex0 + 0] = x;
      data[offset + vertex0 + 1] = y;
      data[offset + vertex1 + 0] = x;
      data[offset + vertex1 + 1] = y;
      data[offset + vertex2 + 0] = x;
      data[offset + vertex2 + 1] = y;
      data[offset + vertex3 + 0] = x;
      data[offset + vertex3 + 1] = y;
      offset += 2;
    }

    if (_useBitmapPivot) {
      var pivotX = bitmap.pivotX.toDouble();
      var pivotY = bitmap.pivotY.toDouble();
      data[offset + vertex0 + 0] = pivotX;
      data[offset + vertex0 + 1] = pivotY;
      data[offset + vertex1 + 0] = pivotX;
      data[offset + vertex1 + 1] = pivotY;
      data[offset + vertex2 + 0] = pivotX;
      data[offset + vertex2 + 1] = pivotY;
      data[offset + vertex3 + 0] = pivotX;
      data[offset + vertex3 + 1] = pivotY;
      offset += 2;
    }

    if (_useBitmapScale) {
      var scaleX = bitmap.scaleX.toDouble();
      var scaleY = bitmap.scaleY.toDouble();
      data[offset + vertex0 + 0] = scaleX;
      data[offset + vertex0 + 1] = scaleY;
      data[offset + vertex1 + 0] = scaleX;
      data[offset + vertex1 + 1] = scaleY;
      data[offset + vertex2 + 0] = scaleX;
      data[offset + vertex2 + 1] = scaleY;
      data[offset + vertex3 + 0] = scaleX;
      data[offset + vertex3 + 1] = scaleY;
      offset += 2;
    }

    if (_useBitmapSkew) {
      var skewX = bitmap.skewX.toDouble();
      var skewY = bitmap.skewY.toDouble();
      data[offset + vertex0 + 0] = skewX;
      data[offset + vertex0 + 1] = skewY;
      data[offset + vertex1 + 0] = skewX;
      data[offset + vertex1 + 1] = skewY;
      data[offset + vertex2 + 0] = skewX;
      data[offset + vertex2 + 1] = skewY;
      data[offset + vertex3 + 0] = skewX;
      data[offset + vertex3 + 1] = skewY;
      offset += 2;
    }

    if (_useBitmapRotation) {
      var rotation = bitmap.rotation.toDouble();
      data[offset + vertex0 + 0] = rotation;
      data[offset + vertex1 + 0] = rotation;
      data[offset + vertex2 + 0] = rotation;
      data[offset + vertex3 + 0] = rotation;
      offset += 1;
    }

    if (_useBitmapAlpha) {
      var alpha = bitmap.alpha.toDouble();
      data[offset + vertex0 + 0] = alpha;
      data[offset + vertex1 + 0] = alpha;
      data[offset + vertex2 + 0] = alpha;
      data[offset + vertex3 + 0] = alpha;
      offset += 1;
    }
  }

  //---------------------------------------------------------------------------

  void updateVertexData(int offset, int length) {
    this.update(4 * stride * offset, 4 * stride * length);
  }

}