part of stagexl.engine;

class RenderTextureQuad {

  final RenderTexture renderTexture;
  final Rectangle<int> sourceRectangle;
  final Rectangle<int> offsetRectangle;
  final int rotation;
  final num pixelRatio;

  final Int16List abList = new Int16List(10);
  final Int16List ixList = new Int16List(6);
  final Float32List vxList = new Float32List(16);

  Int16List _ixListPolygon = null;
  Float32List _vxListPolygon = null;
  bool _hasPolygonShape = false;

  //---------------------------------------------------------------------------

  RenderTextureQuad(this.renderTexture,
                    this.sourceRectangle, this.offsetRectangle,
                    this.rotation, this.pixelRatio) {

    int a = this.rotation;
    int w = a == 0 || a == 2 ? sourceRectangle.width : sourceRectangle.height;
    int h = a == 0 || a == 2 ? sourceRectangle.height : sourceRectangle.width;
    int l = 0 - offsetRectangle.left;
    int t = 0 - offsetRectangle.top;
    int r = l + w;
    int b = t + h;

    // Source coordinates + size

    abList[0] = a == 0 || a == 3 ? sourceRectangle.left : sourceRectangle.right;
    abList[1] = a == 0 || a == 1 ? sourceRectangle.top : sourceRectangle.bottom;
    abList[2] = a == 2 || a == 3 ? sourceRectangle.left : sourceRectangle.right;
    abList[3] = a == 0 || a == 3 ? sourceRectangle.top : sourceRectangle.bottom;
    abList[4] = a == 1 || a == 2 ? sourceRectangle.left : sourceRectangle.right;
    abList[5] = a == 2 || a == 3 ? sourceRectangle.top : sourceRectangle.bottom;
    abList[6] = a == 0 || a == 1 ? sourceRectangle.left : sourceRectangle.right;
    abList[7] = a == 1 || a == 2 ? sourceRectangle.top : sourceRectangle.bottom;
    abList[8] = sourceRectangle.width;
    abList[9] = sourceRectangle.height;

    // Vertex list with x/y/u/v

    vxList[00] = l / pixelRatio;
    vxList[01] = t / pixelRatio;
    vxList[02] = abList[0] / renderTexture.width;
    vxList[03] = abList[1] / renderTexture.height;
    vxList[04] = r / pixelRatio;
    vxList[05] = t / pixelRatio;
    vxList[06] = abList[2] / renderTexture.width;
    vxList[07] = abList[3] / renderTexture.height;
    vxList[08] = r / pixelRatio;
    vxList[09] = b / pixelRatio;
    vxList[10] = abList[4] / renderTexture.width;
    vxList[11] = abList[5] / renderTexture.height;
    vxList[12] = l / pixelRatio;
    vxList[13] = b / pixelRatio;
    vxList[14] = abList[6] / renderTexture.width;
    vxList[15] = abList[7] / renderTexture.height;

    // Index list

    ixList[0] = 0;
    ixList[1] = 1;
    ixList[2] = 2;
    ixList[3] = 0;
    ixList[4] = 2;
    ixList[5] = 3;

    // set default polygon vertices to quad shape

    _vxListPolygon = vxList;
    _ixListPolygon = ixList;
    _hasPolygonShape = false;
  }

  //---------------------------------------------------------------------------

  @deprecated
  Float32List get xyList {

    var list = new Float32List(10);
    list[0] = vxList[00];
    list[1] = vxList[01];
    list[2] = vxList[04];
    list[3] = vxList[05];
    list[4] = vxList[08];
    list[5] = vxList[09];
    list[6] = vxList[12];
    list[7] = vxList[13];

    if (this.rotation == 0 || this.rotation == 2) {
      list[8] = sourceRectangle.width / pixelRatio;
      list[9] = sourceRectangle.height / pixelRatio;
    } else {
      list[8] = sourceRectangle.height / pixelRatio;
      list[9] = sourceRectangle.width / pixelRatio;
    }

    return list;
  }

  //---------------------------------------------------------------------------

  @deprecated
  Float32List get uvList {

    var list = new Float32List(10);
    list[1] = vxList[03];
    list[2] = vxList[06];
    list[3] = vxList[07];
    list[4] = vxList[10];
    list[5] = vxList[11];
    list[6] = vxList[14];
    list[7] = vxList[15];
    list[8] = abList[8] / renderTexture.width;
    list[9] = abList[9] / renderTexture.height;

    return list;
  }

  //---------------------------------------------------------------------------

  factory RenderTextureQuad.slice(
      RenderTextureQuad renderTextureQuad,
      Rectangle<int> sourceRectangle,
      Rectangle<int> offsetRectangle,
      [int rotation = 0]) {

    var renderTexture = renderTextureQuad.renderTexture;
    var pixelRatio = renderTextureQuad.pixelRatio;

    var oldRotation = renderTextureQuad.rotation;
    var oldSourceL = renderTextureQuad.sourceRectangle.left;
    var oldSourceT = renderTextureQuad.sourceRectangle.top;
    var oldSourceR = renderTextureQuad.sourceRectangle.right;
    var oldSourceB = renderTextureQuad.sourceRectangle.bottom;
    var oldOffsetL = renderTextureQuad.offsetRectangle.left;
    var oldOffsetT = renderTextureQuad.offsetRectangle.top;

    var newRotation = (renderTextureQuad.rotation + rotation) % 4;
    var newSourceL = sourceRectangle.left;
    var newSourceT = sourceRectangle.top;
    var newSourceR = sourceRectangle.right;
    var newSourceB = sourceRectangle.bottom;
    var newOffsetL = offsetRectangle.left;
    var newOffsetT = offsetRectangle.top;
    var newOffsetW = offsetRectangle.width;
    var newOffsetH = offsetRectangle.height;

    var tmpSourceL = 0;
    var tmpSourceT = 0;
    var tmpSourceR = 0;
    var tmpSourceB = 0;

    if (oldRotation == 0) {
      tmpSourceL = oldSourceL + oldOffsetL + newSourceL;
      tmpSourceT = oldSourceT + oldOffsetT + newSourceT;
      tmpSourceR = oldSourceL + oldOffsetL + newSourceR;
      tmpSourceB = oldSourceT + oldOffsetT + newSourceB;
    } else if (oldRotation == 1) {
      tmpSourceL = oldSourceR - oldOffsetT - newSourceB;
      tmpSourceT = oldSourceT + oldOffsetL + newSourceL;
      tmpSourceR = oldSourceR - oldOffsetT - newSourceT;
      tmpSourceB = oldSourceT + oldOffsetL + newSourceR;
    } else if (oldRotation == 2) {
      tmpSourceL = oldSourceR - oldOffsetL - newSourceR;
      tmpSourceT = oldSourceB - oldOffsetT - newSourceB;
      tmpSourceR = oldSourceR - oldOffsetL - newSourceL;
      tmpSourceB = oldSourceB - oldOffsetT - newSourceT;
    } else if (oldRotation == 3) {
      tmpSourceL = oldSourceL + oldOffsetT + newSourceT;
      tmpSourceT = oldSourceB - oldOffsetL - newSourceR;
      tmpSourceR = oldSourceL + oldOffsetT + newSourceB;
      tmpSourceB = oldSourceB - oldOffsetL - newSourceL;
    }

    newSourceL = clampInt(tmpSourceL, oldSourceL, oldSourceR);
    newSourceT = clampInt(tmpSourceT, oldSourceT, oldSourceB);
    newSourceR = clampInt(tmpSourceR, oldSourceL, oldSourceR);
    newSourceB = clampInt(tmpSourceB, oldSourceT, oldSourceB);

    if (newRotation == 0) {
      newOffsetL += tmpSourceL - newSourceL;
      newOffsetT += tmpSourceT - newSourceT;
    } else if (newRotation == 1) {
      newOffsetL += tmpSourceT - newSourceT;
      newOffsetT += newSourceR - tmpSourceR;
    } else if (newRotation == 2) {
      newOffsetL += newSourceR - tmpSourceR;
      newOffsetT += tmpSourceB - newSourceB;
    } else if (newRotation == 3) {
      newOffsetL += newSourceB - tmpSourceB;
      newOffsetT += newSourceL - tmpSourceL;
    }

    var newSourceW = newSourceR - newSourceL;
    var newSourceH = newSourceB - newSourceT;

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(newSourceL, newSourceT, newSourceW, newSourceH),
        new Rectangle<int>(newOffsetL, newOffsetT, newOffsetW, newOffsetH),
        newRotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  num get targetWidth => offsetRectangle.width / pixelRatio;
  num get targetHeight => offsetRectangle.height / pixelRatio;

  Float32List get vxListPolygon => _vxListPolygon;
  Int16List get ixListPolygon => _ixListPolygon;
  bool get hasPolygonShape => _hasPolygonShape;

  Rectangle<num> get targetRectangle {
    num l = offsetRectangle.left / pixelRatio;
    num t = offsetRectangle.top / pixelRatio;
    num w = offsetRectangle.width / pixelRatio;
    num h = offsetRectangle.height / pixelRatio;
    return new Rectangle<num>(l, t, w, h);
  }

  RenderTextureQuad withPixelRatio(num pixelRatio) {
    return new RenderTextureQuad(this.renderTexture,
        this.sourceRectangle, this.offsetRectangle,
        this.rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  void removePolygonShape() {
    _vxListPolygon = this.vxList;
    _ixListPolygon = this.ixList;
    _hasPolygonShape = false;
  }

  void applyPolygonShape(Float32List vxList, Int16List ixList) {
    _vxListPolygon = vxList;
    _ixListPolygon = ixList;
    _hasPolygonShape = true;
  }

  //---------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform target coordinates to texture coordinates.
  ///
  /// Texture coordinates are in the range from (0, 0) to (width, height).
  /// Target coordinates take the [pixelRatio] into account.

  Matrix get drawMatrix {

    var pr = this.pixelRatio;

    if (rotation == 0) {
      var tx = sourceRectangle.left + offsetRectangle.left;
      var ty = sourceRectangle.top + offsetRectangle.top;
      return new Matrix(pr, 0.0, 0.0, pr, tx, ty);
    } else if (rotation == 1) {
      var tx = sourceRectangle.right - offsetRectangle.top;
      var ty = sourceRectangle.top + offsetRectangle.left;
      return new Matrix(0.0, pr, 0.0 - pr, 0.0, tx, ty);
    } else if (rotation == 2) {
      var tx = sourceRectangle.right - offsetRectangle.left;
      var ty = sourceRectangle.bottom - offsetRectangle.top;
      return new Matrix(0.0 - pr, 0.0, 0.0, 0.0 - pr, tx, ty);
    } else if (rotation == 3) {
      var tx = sourceRectangle.left + offsetRectangle.top;
      var ty = sourceRectangle.bottom - offsetRectangle.left;
      return new Matrix(0.0, 0.0 - pr, pr, 0.0, tx, ty);
    } else {
      throw new Error();
    }
  }

  //---------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform target coordinates to sampler coordinates.
  ///
  /// Sampler coordinate are in the range from (0, 0) to (1, 1).
  /// Target coordinates take the [pixelRatio] into account.

  Matrix get samplerMatrix {

    var pr = this.pixelRatio;
    var sx = 1.0 / this.renderTexture.width;
    var sy = 1.0 / this.renderTexture.height;

    if (rotation == 0) {
      var tx = sourceRectangle.left + offsetRectangle.left;
      var ty = sourceRectangle.top + offsetRectangle.top;
      return new Matrix(sx * pr, 0.0, 0.0, sy * pr, sx * tx, sy * ty);
    } else if (rotation == 1) {
      var tx = sourceRectangle.right - offsetRectangle.top;
      var ty = sourceRectangle.top + offsetRectangle.left;
      return new Matrix(0.0, sy * pr, 0.0 - sx * pr, 0.0, sx * tx, sy * ty);
    } else if (rotation == 2) {
      var tx = sourceRectangle.right - offsetRectangle.left;
      var ty = sourceRectangle.bottom - offsetRectangle.top;
      return new Matrix(0.0 - sx * pr, 0.0, 0.0, 0.0 - sy * pr, sx * tx, sy * ty);
    } else if (rotation == 3) {
      var tx = sourceRectangle.left + offsetRectangle.top;
      var ty = sourceRectangle.bottom - offsetRectangle.left;
      return new Matrix(0.0, 0.0 - sy * pr, sx * pr, 0.0, sx * tx, sy * ty);
    } else {
      throw new Error();
    }
  }

  //---------------------------------------------------------------------------

  /// Clips a new RenderTextureQuad from this RenderTextureQuad. The offset
  /// of the new RenderTextureQuad will be adjusted to match the origin of
  /// this RenderTextureQuad.
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad clip(Rectangle<int> rectangle) {
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();
    int ow = this.offsetRectangle.width;
    int oh = this.offsetRectangle.height;
    var sourceRectangle = new Rectangle<int>(rL, rT, rR - rL, rB - rT);
    var offsetRectangle = new Rectangle<int>(0 - rL, 0 - rT, ow, oh);
    return new RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
  }

  /// Cuts a new RenderTextureQuad out of this RenderTextureQuad. The offset
  /// of the new RenderTextureQuad will be adjusted to match the origin of
  /// the [rectangle].
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad cut(Rectangle<int> rectangle) {
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();
    var sourceRectangle = new Rectangle<int>(rL, rT, rR - rL, rB - rT);
    var offsetRectangle = new Rectangle<int>(0, 0, rR - rL, rB - rT);
    return new RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
  }

  //---------------------------------------------------------------------------

  ImageData createImageData() {
    var rect = sourceRectangle;
    var context = renderTexture.canvas.context2D;
    return context.createImageData(rect.width, rect.height);
  }

  ImageData getImageData() {
    var rect = sourceRectangle;
    var context = renderTexture.canvas.context2D;
    return context.getImageData(rect.left, rect.top, rect.width, rect.height);
  }

  void putImageData(ImageData imageData) {
    var rect = sourceRectangle;
    var context = renderTexture.canvas.context2D;
    context.putImageData(imageData, rect.left, rect.top);
  }

}
