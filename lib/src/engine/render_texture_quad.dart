part of stagexl.engine;

class RenderTextureQuad {
  final RenderTexture renderTexture;
  final Rectangle<int> sourceRectangle;
  final Rectangle<int> offsetRectangle;
  final int rotation;
  final num pixelRatio;

  final Int16List ixListQuad = Int16List(6);
  final Float32List vxListQuad = Float32List(16);

  late Int16List _ixList;
  late Float32List _vxList;
  bool _hasCustomVertices = false;

  //---------------------------------------------------------------------------

  RenderTextureQuad(this.renderTexture, this.sourceRectangle,
      this.offsetRectangle, this.rotation, this.pixelRatio) {
    var sr = sourceRectangle;
    var or = offsetRectangle;
    var rt = renderTexture;
    var pr = pixelRatio;

    // Vertex list [x/y]

    if (rotation == 0 || rotation == 2) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[08] = vxListQuad[04] = (0 - or.left + sr.width) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.height) / pr;
    } else if (rotation == 1 || rotation == 3) {
      vxListQuad[00] = vxListQuad[12] = (0 - or.left) / pr;
      vxListQuad[01] = vxListQuad[05] = (0 - or.top) / pr;
      vxListQuad[08] = vxListQuad[04] = (0 - or.left + sr.height) / pr;
      vxListQuad[09] = vxListQuad[13] = (0 - or.top + sr.width) / pr;
    } else {
      throw Error();
    }

    // Vertex list [u/v]

    if (rotation == 0) {
      vxListQuad[02] = vxListQuad[14] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.top / rt.height;
      vxListQuad[10] = vxListQuad[06] = sr.right / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.bottom / rt.height;
    } else if (rotation == 1) {
      vxListQuad[02] = vxListQuad[06] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.top / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.left / rt.width;
      vxListQuad[11] = vxListQuad[07] = sr.bottom / rt.height;
    } else if (rotation == 2) {
      vxListQuad[02] = vxListQuad[14] = sr.right / rt.width;
      vxListQuad[03] = vxListQuad[07] = sr.bottom / rt.height;
      vxListQuad[10] = vxListQuad[06] = sr.left / rt.width;
      vxListQuad[11] = vxListQuad[15] = sr.top / rt.height;
    } else if (rotation == 3) {
      vxListQuad[02] = vxListQuad[06] = sr.left / rt.width;
      vxListQuad[03] = vxListQuad[15] = sr.bottom / rt.height;
      vxListQuad[10] = vxListQuad[14] = sr.right / rt.width;
      vxListQuad[11] = vxListQuad[07] = sr.top / rt.height;
    } else {
      throw Error();
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

  factory RenderTextureQuad.slice(RenderTextureQuad renderTextureQuad,
      Rectangle<int> sourceRectangle, Rectangle<int> offsetRectangle,
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

    var otation = (renderTextureQuad.rotation + rotation) % 4;
    var ourceL = sourceRectangle.left;
    var ourceT = sourceRectangle.top;
    var ourceR = sourceRectangle.right;
    var ourceB = sourceRectangle.bottom;
    var ffsetL = offsetRectangle.left;
    var ffsetT = offsetRectangle.top;
    var ffsetW = offsetRectangle.width;
    var ffsetH = offsetRectangle.height;

    var tmpSourceL = 0;
    var tmpSourceT = 0;
    var tmpSourceR = 0;
    var tmpSourceB = 0;

    if (oldRotation == 0) {
      tmpSourceL = oldSourceL + oldOffsetL + ourceL;
      tmpSourceT = oldSourceT + oldOffsetT + ourceT;
      tmpSourceR = oldSourceL + oldOffsetL + ourceR;
      tmpSourceB = oldSourceT + oldOffsetT + ourceB;
    } else if (oldRotation == 1) {
      tmpSourceL = oldSourceR - oldOffsetT - ourceB;
      tmpSourceT = oldSourceT + oldOffsetL + ourceL;
      tmpSourceR = oldSourceR - oldOffsetT - ourceT;
      tmpSourceB = oldSourceT + oldOffsetL + ourceR;
    } else if (oldRotation == 2) {
      tmpSourceL = oldSourceR - oldOffsetL - ourceR;
      tmpSourceT = oldSourceB - oldOffsetT - ourceB;
      tmpSourceR = oldSourceR - oldOffsetL - ourceL;
      tmpSourceB = oldSourceB - oldOffsetT - ourceT;
    } else if (oldRotation == 3) {
      tmpSourceL = oldSourceL + oldOffsetT + ourceT;
      tmpSourceT = oldSourceB - oldOffsetL - ourceR;
      tmpSourceR = oldSourceL + oldOffsetT + ourceB;
      tmpSourceB = oldSourceB - oldOffsetL - ourceL;
    }

    ourceL = tmpSourceL.clamp(oldSourceL, oldSourceR);
    ourceT = tmpSourceT.clamp(oldSourceT, oldSourceB);
    ourceR = tmpSourceR.clamp(oldSourceL, oldSourceR);
    ourceB = tmpSourceB.clamp(oldSourceT, oldSourceB);

    if (otation == 0) {
      ffsetL += tmpSourceL - ourceL;
      ffsetT += tmpSourceT - ourceT;
    } else if (otation == 1) {
      ffsetL += tmpSourceT - ourceT;
      ffsetT += ourceR - tmpSourceR;
    } else if (otation == 2) {
      ffsetL += ourceR - tmpSourceR;
      ffsetT += tmpSourceB - ourceB;
    } else if (otation == 3) {
      ffsetL += ourceB - tmpSourceB;
      ffsetT += ourceL - tmpSourceL;
    }

    var ourceW = ourceR - ourceL;
    var ourceH = ourceB - ourceT;

    return RenderTextureQuad(
        renderTexture,
        Rectangle<int>(ourceL, ourceT, ourceW, ourceH),
        Rectangle<int>(ffsetL, ffsetT, ffsetW, ffsetH),
        otation,
        pixelRatio);
  }

  //---------------------------------------------------------------------------

  bool get isEquivalentToSource {
    return
        (rotation == 0) &&
        !_hasCustomVertices &&
        (sourceRectangle.left == 0 &&
            sourceRectangle.top == 0 &&
            sourceRectangle.width == renderTexture.width &&
            sourceRectangle.height == renderTexture.height);
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
    return Rectangle<num>(l, t, w, h);
  }

  RenderTextureQuad withPixelRatio([num pixelRatio = 1.0]) {
    return RenderTextureQuad(
        renderTexture, sourceRectangle, offsetRectangle, rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  void setQuadVertices() {
    _vxList = vxListQuad;
    _ixList = ixListQuad;
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
    var pr = pixelRatio;

    if (rotation == 0) {
      var tx = sourceRectangle.left + offsetRectangle.left;
      var ty = sourceRectangle.top + offsetRectangle.top;
      return Matrix(pr, 0.0, 0.0, pr, tx, ty);
    } else if (rotation == 1) {
      var tx = sourceRectangle.right - offsetRectangle.top;
      var ty = sourceRectangle.top + offsetRectangle.left;
      return Matrix(0.0, pr, 0.0 - pr, 0.0, tx, ty);
    } else if (rotation == 2) {
      var tx = sourceRectangle.right - offsetRectangle.left;
      var ty = sourceRectangle.bottom - offsetRectangle.top;
      return Matrix(0.0 - pr, 0.0, 0.0, 0.0 - pr, tx, ty);
    } else if (rotation == 3) {
      var tx = sourceRectangle.left + offsetRectangle.top;
      var ty = sourceRectangle.bottom - offsetRectangle.left;
      return Matrix(0.0, 0.0 - pr, pr, 0.0, tx, ty);
    } else {
      throw Error();
    }
  }

  //---------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform target coordinates to sampler coordinates.
  ///
  /// Sampler coordinate are in the range from (0, 0) to (1, 1).
  /// Target coordinates take the [pixelRatio] into account.

  Matrix get samplerMatrix {
    var pr = pixelRatio;
    var sx = 1.0 / renderTexture.width;
    var sy = 1.0 / renderTexture.height;

    if (rotation == 0) {
      var tx = sourceRectangle.left + offsetRectangle.left;
      var ty = sourceRectangle.top + offsetRectangle.top;
      return Matrix(sx * pr, 0.0, 0.0, sy * pr, sx * tx, sy * ty);
    } else if (rotation == 1) {
      var tx = sourceRectangle.right - offsetRectangle.top;
      var ty = sourceRectangle.top + offsetRectangle.left;
      return Matrix(0.0, sy * pr, 0.0 - sx * pr, 0.0, sx * tx, sy * ty);
    } else if (rotation == 2) {
      var tx = sourceRectangle.right - offsetRectangle.left;
      var ty = sourceRectangle.bottom - offsetRectangle.top;
      return Matrix(0.0 - sx * pr, 0.0, 0.0, 0.0 - sy * pr, sx * tx, sy * ty);
    } else if (rotation == 3) {
      var tx = sourceRectangle.left + offsetRectangle.top;
      var ty = sourceRectangle.bottom - offsetRectangle.left;
      return Matrix(0.0, 0.0 - sy * pr, sx * pr, 0.0, sx * tx, sy * ty);
    } else {
      throw Error();
    }
  }

  //---------------------------------------------------------------------------

  /// Clips a RenderTextureQuad from this RenderTextureQuad. The offset
  /// of the RenderTextureQuad will be adjusted to match the origin of
  /// this RenderTextureQuad.
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad clip(Rectangle<num> rectangle) {
    var rL = (rectangle.left * pixelRatio).round();
    var rT = (rectangle.top * pixelRatio).round();
    var rR = (rectangle.right * pixelRatio).round();
    var rB = (rectangle.bottom * pixelRatio).round();
    var ow = this.offsetRectangle.width;
    var oh = this.offsetRectangle.height;
    var sourceRectangle = Rectangle<int>(rL, rT, rR - rL, rB - rT);
    var offsetRectangle = Rectangle<int>(0 - rL, 0 - rT, ow, oh);
    return RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
  }

  /// Cuts a RenderTextureQuad out of this RenderTextureQuad. The offset
  /// of the RenderTextureQuad will be adjusted to match the origin of
  /// the [rectangle].
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad cut(Rectangle<num> rectangle) {
    var rL = (rectangle.left * pixelRatio).round();
    var rT = (rectangle.top * pixelRatio).round();
    var rR = (rectangle.right * pixelRatio).round();
    var rB = (rectangle.bottom * pixelRatio).round();
    var sourceRectangle = Rectangle<int>(rL, rT, rR - rL, rB - rT);
    var offsetRectangle = Rectangle<int>(0, 0, rR - rL, rB - rT);
    return RenderTextureQuad.slice(this, sourceRectangle, offsetRectangle);
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
