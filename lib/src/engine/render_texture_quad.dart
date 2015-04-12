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

  num get pixelWidth => offsetRectangle.width / pixelRatio;
  num get pixelHeight => offsetRectangle.height / pixelRatio;

  Rectangle<num> get pixelRectangle {
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
  /// transform pixel coordinates to texture coordinates.
  ///
  /// Texture coordinates are in the range from (0, 0) to (width, height).
  /// Pixel coordinates are not mulitplied by the [pixelRatio].

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
  /// transform pixel coordinates to sampler coordinates.
  ///
  /// Sampler coordinate are in the range from (0, 0) to (1, 1).
  /// Pixel coordinates are not mulitplied by the [pixelRatio].

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
      srcL = minInt(sR, maxInt(sL, sL + oL + rL));
      srcT = minInt(sB, maxInt(sT, sT + oT + rT));
      srcR = maxInt(sL, minInt(sR, sL + oL + rR));
      srcB = maxInt(sT, minInt(sB, sT + oT + rB));
      ofsL = oL - srcL + sL;
      ofsT = oT - srcT + sT;
    } else if (rotation == 1) {
      srcL = minInt(sR, maxInt(sL, sR - oT - rB));
      srcT = minInt(sB, maxInt(sT, sT + oL + rL));
      srcR = maxInt(sL, minInt(sR, sR - oT - rT));
      srcB = maxInt(sT, minInt(sB, sT + oL + rR));
      ofsL = oL - srcT + sT;
      ofsT = oT + srcR - sR;
    } else if (rotation == 2) {
      srcL = minInt(sR, maxInt(sL, sR - oL - rR));
      srcT = minInt(sB, maxInt(sT, sB - oT - rB));
      srcR = maxInt(sL, minInt(sR, sR - oL - rL));
      srcB = maxInt(sT, minInt(sB, sB - oT - rT));
      ofsL = oL + srcR - sR;
      ofsT = oT + srcB - sB;
    } else if (rotation == 3) {
      srcL = minInt(sR, maxInt(sL, sL + oT + rT));
      srcT = minInt(sB, maxInt(sT, sB - oL - rR));
      srcR = maxInt(sL, minInt(sR, sL + oT + rB));
      srcB = maxInt(sT, minInt(sB, sB - oL - rL));
      ofsL = oL + srcB - sB;
      ofsT = oT - srcL + sL;
    }

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(srcL, srcT, srcR - srcL, srcB - srcT),
        new Rectangle<int>(ofsL, ofsT, oR - oL, oB - oT),
        rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

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
      srcL = minInt(sR, maxInt(sL, sL + oL + rL));
      srcT = minInt(sB, maxInt(sT, sT + oT + rT));
      srcR = maxInt(sL, minInt(sR, sL + oL + rR));
      srcB = maxInt(sT, minInt(sB, sT + oT + rB));
      ofsL = oL - srcL + sL + rL;
      ofsT = oT - srcT + sT + rT;
    } else if (rotation == 1) {
      srcL = minInt(sR, maxInt(sL, sR - oT - rB));
      srcT = minInt(sB, maxInt(sT, sT - oL + rL));
      srcR = maxInt(sL, minInt(sR, sR - oT - rT));
      srcB = maxInt(sT, minInt(sB, sT - oL + rR));
      ofsL = oL - srcT + sT + rL;
      ofsT = oT + srcR - sR + rT;
    } else if (rotation == 2) {
      srcL = minInt(sR, maxInt(sL, sR - oL - rR));
      srcT = minInt(sB, maxInt(sT, sB - oT - rB));
      srcR = maxInt(sL, minInt(sR, sR - oL - rL));
      srcB = maxInt(sT, minInt(sB, sB - oT - rT));
      ofsL = oL + srcR - sR + rL;
      ofsT = oT + srcB - sB + rT;
    } else if (rotation == 3) {
      srcL = minInt(sR, maxInt(sL, sL + oT + rT));
      srcT = minInt(sB, maxInt(sT, sB - oL - rR));
      srcR = maxInt(sL, minInt(sR, sL + oT + rB));
      srcB = maxInt(sT, minInt(sB, sB - oL - rL));
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