part of stagexl.engine;

class RenderTextureQuad {

  final RenderTexture renderTexture;
  final Rectangle<int> sourceRectangle;
  final Rectangle<int> offsetRectangle;
  final int rotation;
  final num pixelRatio;

  final Float32List pqList = new Float32List(10);
  final Float32List uvList = new Float32List(10);
  final Int32List xyList = new Int32List(10);

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

    // Vertex positions + size

    pqList[0] = pqList[6] = l / pixelRatio;
    pqList[1] = pqList[3] = t / pixelRatio;
    pqList[2] = pqList[4] = r / pixelRatio;
    pqList[5] = pqList[7] = b / pixelRatio;
    pqList[8] = w / pixelRatio;
    pqList[9] = h / pixelRatio;

    // Source coordinates + size

    xyList[0] = a == 0 || a == 3 ? sourceRectangle.left : sourceRectangle.right;
    xyList[1] = a == 0 || a == 1 ? sourceRectangle.top : sourceRectangle.bottom;
    xyList[2] = a == 2 || a == 3 ? sourceRectangle.left : sourceRectangle.right;
    xyList[3] = a == 0 || a == 3 ? sourceRectangle.top : sourceRectangle.bottom;
    xyList[4] = a == 1 || a == 2 ? sourceRectangle.left : sourceRectangle.right;
    xyList[5] = a == 2 || a == 3 ? sourceRectangle.top : sourceRectangle.bottom;
    xyList[6] = a == 0 || a == 1 ? sourceRectangle.left : sourceRectangle.right;
    xyList[7] = a == 1 || a == 2 ? sourceRectangle.top : sourceRectangle.bottom;
    xyList[8] = sourceRectangle.width;
    xyList[9] = sourceRectangle.height;

    // WebGL coordinates + size

    uvList[0] = xyList[0] / renderTexture.width;
    uvList[1] = xyList[1] / renderTexture.height;
    uvList[2] = xyList[2] / renderTexture.width;
    uvList[3] = xyList[3] / renderTexture.height;
    uvList[4] = xyList[4] / renderTexture.width;
    uvList[5] = xyList[5] / renderTexture.height;
    uvList[6] = xyList[6] / renderTexture.width;
    uvList[7] = xyList[7] / renderTexture.height;
    uvList[8] = xyList[8] / renderTexture.width;
    uvList[9] = xyList[9] / renderTexture.height;
  }

  //---------------------------------------------------------------------------

  num get targetWidth => offsetRectangle.width / pixelRatio;
  num get targetHeight => offsetRectangle.height / pixelRatio;

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

    int sL = sourceRectangle.left;
    int sT = sourceRectangle.top;
    int sR = sourceRectangle.right;
    int sB = sourceRectangle.bottom;
    int oL = offsetRectangle.left;
    int oT = offsetRectangle.top;
    int oR = offsetRectangle.right;
    int oB = offsetRectangle.bottom;
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();

    int srcL = sL;
    int srcT = sT;
    int srcR = sR;
    int srcB = sB;
    int ofsL = oL;
    int ofsT = oT;

    if (rotation == 0) {
      srcL = clampInt(sL + oL + rL, sL, sR);
      srcT = clampInt(sT + oT + rT, sT, sB);
      srcR = clampInt(sL + oL + rR, sL, sR);
      srcB = clampInt(sT + oT + rB, sT, sB);
      ofsL = oL - srcL + sL;
      ofsT = oT - srcT + sT;
    } else if (rotation == 1) {
      srcL = clampInt(sR - oT - rB, sL, sR);
      srcT = clampInt(sT + oL + rL, sT, sB);
      srcR = clampInt(sR - oT - rT, sL, sR);
      srcB = clampInt(sT + oL + rR, sT, sB);
      ofsL = oL - srcT + sT;
      ofsT = oT + srcR - sR;
    } else if (rotation == 2) {
      srcL = clampInt(sR - oL - rR, sL, sR);
      srcT = clampInt(sB - oT - rB, sT, sB);
      srcR = clampInt(sR - oL - rL, sL, sR);
      srcB = clampInt(sB - oT - rT, sT, sB);
      ofsL = oL + srcR - sR;
      ofsT = oT + srcB - sB;
    } else if (rotation == 3) {
      srcL = clampInt(sL + oT + rT, sL, sR);
      srcT = clampInt(sB - oL - rR, sT, sB);
      srcR = clampInt(sL + oT + rB, sL, sR);
      srcB = clampInt(sB - oL - rL, sT, sB);
      ofsL = oL + srcB - sB;
      ofsT = oT - srcL + sL;
    }

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(srcL, srcT, srcR - srcL, srcB - srcT),
        new Rectangle<int>(ofsL, ofsT, oR - oL, oB - oT),
        rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  /// Cuts a new RenderTextureQuad out of this RenderTextureQuad. The offset
  /// of the new RenderTextureQuad will be adjusted to match the origin of
  /// the [rectangle].
  ///
  /// The [rectangle] is in target coordinates. Those coordinates take the
  /// [pixelRatio] into account. Please read more about HiDpi textures to
  /// learn more about this topic.

  RenderTextureQuad cut(Rectangle<int> rectangle) {

    int sL = sourceRectangle.left;
    int sT = sourceRectangle.top;
    int sR = sourceRectangle.right;
    int sB = sourceRectangle.bottom;
    int oL = offsetRectangle.left;
    int oT = offsetRectangle.top;
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();

    int srcL = sL;
    int srcT = sT;
    int srcR = sR;
    int srcB = sB;
    int ofsL = oL;
    int ofsT = oT;

    if (rotation == 0) {
      srcL = clampInt(sL + oL + rL, sL, sR);
      srcT = clampInt(sT + oT + rT, sT, sB);
      srcR = clampInt(sL + oL + rR, sL, sR);
      srcB = clampInt(sT + oT + rB, sT, sB);
      ofsL = oL - srcL + sL + rL;
      ofsT = oT - srcT + sT + rT;
    } else if (rotation == 1) {
      srcL = clampInt(sR - oT - rB, sL, sR);
      srcT = clampInt(sT - oL + rL, sT, sB);
      srcR = clampInt(sR - oT - rT, sL, sR);
      srcB = clampInt(sT - oL + rR, sT, sB);
      ofsL = oL - srcT + sT + rL;
      ofsT = oT + srcR - sR + rT;
    } else if (rotation == 2) {
      srcL = clampInt(sR - oL - rR, sL, sR);
      srcT = clampInt(sB - oT - rB, sT, sB);
      srcR = clampInt(sR - oL - rL, sL, sR);
      srcB = clampInt(sB - oT - rT, sT, sB);
      ofsL = oL + srcR - sR + rL;
      ofsT = oT + srcB - sB + rT;
    } else if (rotation == 3) {
      srcL = clampInt(sL + oT + rT, sL, sR);
      srcT = clampInt(sB - oL - rR, sT, sB);
      srcR = clampInt(sL + oT + rB, sL, sR);
      srcB = clampInt(sB - oL - rL, sT, sB);
      ofsL = oL + srcB - sB + rL;
      ofsT = oT - srcL + sL + rT;
    }

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(srcL, srcT, srcR - srcL, srcB - srcT),
        new Rectangle<int>(ofsL, ofsT, rR - rL, rB - rT),
        rotation, pixelRatio);
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