part of stagexl.engine;

class RenderTextureQuad {

  final RenderTexture renderTexture;
  final Rectangle<int> sourceRectangle;
  final Rectangle<int> offsetRectangle;
  final int rotation;
  final num pixelRatio;

  final Int16List ixListQuad = new Int16List(6);
  final Float32List vxListQuad = new Float32List(16);

  Int16List _ixList = null;
  Float32List _vxList = null;
  bool _hasCustomVertices = false;

  //---------------------------------------------------------------------------

  RenderTextureQuad(this.renderTexture,
                    this.sourceRectangle, this.offsetRectangle,
                    this.rotation, this.pixelRatio) {

    Rectangle<int> sr = this.sourceRectangle;
    Rectangle<int> or = this.offsetRectangle;
    RenderTexture rt = this.renderTexture;
    num pr = this.pixelRatio;

    // Vertex list [x/y]

    if (this.rotation == 0 || this.rotation == 2) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[04] = vxListQuad[08] = (0 - or.left + sr.width) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.height) / pr;
    } else if (this.rotation == 1 || this.rotation == 3) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[04] = vxListQuad[08] = (0 - or.left + sr.height) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.width) / pr;
    } else {
      throw new Error();
    }

    // Vertex list [u/v]

    if (this.rotation == 0) {
      vxListQuad[02] = vxListQuad[14] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.top / rt.height;
      vxListQuad[06] = vxListQuad[10] = sr.right / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.bottom / rt.height;
    } else if (this.rotation == 1) {
      vxListQuad[02] = vxListQuad[06] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.top / rt.height;
      vxListQuad[07] = vxListQuad[11] = sr.bottom / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.left / rt.width;
    } else if (this.rotation == 2) {
      vxListQuad[02] = vxListQuad[14] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.bottom / rt.height;
      vxListQuad[06] = vxListQuad[10] = sr.left / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.top / rt.height;
    } else if (this.rotation == 3) {
      vxListQuad[02] = vxListQuad[06] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.bottom / rt.height;
      vxListQuad[07] = vxListQuad[11] = sr.top / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.right / rt.width;
    } else {
      throw new Error();
    }

    // Index list

    ixListQuad[0] = 0;
    ixListQuad[1] = 1;
    ixListQuad[2] = 2;
    ixListQuad[3] = 0;
    ixListQuad[4] = 2;
    ixListQuad[5] = 3;

    // set default vertices to quad vertices

    _vxList = vxListQuad;
    _ixList = ixListQuad;
    _hasCustomVertices = false;
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

  Float32List get vxList => _vxList;
  Int16List get ixList => _ixList;
  bool get hasCustomVertices => _hasCustomVertices;

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

  void setQuadVertices() {
    _vxList = this.vxListQuad;
    _ixList = this.ixListQuad;
    _hasCustomVertices = false;
  }

  void setCustomVertices(Float32List vxList, Int16List ixList) {
    _vxList = vxList;
    _ixList = ixList;
    _hasCustomVertices = true;
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

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @deprecated
  Float32List get xyList {
    var list = new Float32List(10);
    list[0] = vxListQuad[00];
    list[1] = vxListQuad[01];
    list[2] = vxListQuad[04];
    list[3] = vxListQuad[05];
    list[4] = vxListQuad[08];
    list[5] = vxListQuad[09];
    list[6] = vxListQuad[12];
    list[7] = vxListQuad[13];
    if (this.rotation == 0 || this.rotation == 2) {
      list[8] = sourceRectangle.width / pixelRatio;
      list[9] = sourceRectangle.height / pixelRatio;
    } else {
      list[8] = sourceRectangle.height / pixelRatio;
      list[9] = sourceRectangle.width / pixelRatio;
    }
    return list;
  }

  @deprecated
  Float32List get uvList {
    var list = new Float32List(10);
    list[0] = vxListQuad[02];
    list[1] = vxListQuad[03];
    list[2] = vxListQuad[06];
    list[3] = vxListQuad[07];
    list[4] = vxListQuad[10];
    list[5] = vxListQuad[11];
    list[6] = vxListQuad[14];
    list[7] = vxListQuad[15];
    list[8] = sourceRectangle.width / renderTexture.width;
    list[9] = sourceRectangle.height / renderTexture.height;
    return list;
  }

  @deprecated
  Int16List get abList {
    var list = new Int16List(10);
    var sr = sourceRectangle;
    list[0] = rotation == 0 || rotation == 3 ? sr.left : sr.right;
    list[1] = rotation == 0 || rotation == 1 ? sr.top : sr.bottom;
    list[2] = rotation == 2 || rotation == 3 ? sr.left : sr.right;
    list[3] = rotation == 0 || rotation == 3 ? sr.top : sr.bottom;
    list[4] = rotation == 1 || rotation == 2 ? sr.left : sr.right;
    list[5] = rotation == 2 || rotation == 3 ? sr.top : sr.bottom;
    list[6] = rotation == 0 || rotation == 1 ? sr.left : sr.right;
    list[7] = rotation == 1 || rotation == 2 ? sr.top : sr.bottom;
    list[8] = sr.width;
    list[9] = sr.height;
    return list;
  }


}
