part of stagexl.engine;

class RenderTextureQuad {

  final RenderTexture renderTexture;
  final Rectangle<int> textureRectangle;
  final Rectangle<int> sourceRectangle;
  final int rotation;
  final num pixelRatio;

  final Float32List pqList = new Float32List(10);
  final Float32List uvList = new Float32List(10);
  final Int32List xyList = new Int32List(10);

  //---------------------------------------------------------------------------

  RenderTextureQuad(this.renderTexture,
                    this.textureRectangle, this.sourceRectangle,
                    this.rotation, this.pixelRatio) {

    int a = this.rotation;
    int w = a == 0 || a == 2 ? textureRectangle.width : textureRectangle.height;
    int h = a == 0 || a == 2 ? textureRectangle.height : textureRectangle.width;
    int l = 0 - sourceRectangle.left;
    int t = 0 - sourceRectangle.top;
    int r = l + w;
    int b = t + h;

    // Vertex positions + size

    pqList[0] = pqList[6] = l / pixelRatio;
    pqList[1] = pqList[3] = t / pixelRatio;
    pqList[2] = pqList[4] = r / pixelRatio;
    pqList[5] = pqList[7] = b / pixelRatio;
    pqList[8] = w / pixelRatio;
    pqList[9] = h / pixelRatio;

    // Texture coordinates + size

    xyList[0] = a == 0 || a == 3 ? textureRectangle.left : textureRectangle.right;
    xyList[1] = a == 0 || a == 1 ? textureRectangle.top : textureRectangle.bottom;
    xyList[2] = a == 2 || a == 3 ? textureRectangle.left : textureRectangle.right;
    xyList[3] = a == 0 || a == 3 ? textureRectangle.top : textureRectangle.bottom;
    xyList[4] = a == 1 || a == 2 ? textureRectangle.left : textureRectangle.right;
    xyList[5] = a == 2 || a == 3 ? textureRectangle.top : textureRectangle.bottom;
    xyList[6] = a == 0 || a == 1 ? textureRectangle.left : textureRectangle.right;
    xyList[7] = a == 1 || a == 2 ? textureRectangle.top : textureRectangle.bottom;
    xyList[8] = textureRectangle.width;
    xyList[9] = textureRectangle.height;

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

  num get pixelWidth => sourceRectangle.width / pixelRatio;
  num get pixelHeight => sourceRectangle.height / pixelRatio;

  Rectangle<num> get pixelRectangle {
    num l = sourceRectangle.left / pixelRatio;
    num t = sourceRectangle.top / pixelRatio;
    num w = sourceRectangle.width / pixelRatio;
    num h = sourceRectangle.height / pixelRatio;
    return new Rectangle<num>(l, t, w, h);
  }

  RenderTextureQuad withPixelRatio(num pixelRatio) {
    return new RenderTextureQuad(this.renderTexture,
        this.textureRectangle, this.sourceRectangle,
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
      var tx = textureRectangle.left + sourceRectangle.left;
      var ty = textureRectangle.top + sourceRectangle.top;
      return new Matrix(pr, 0.0, 0.0, pr, tx, ty);
    } else if (rotation == 1) {
      var tx = textureRectangle.right - sourceRectangle.top;
      var ty = textureRectangle.top + sourceRectangle.left;
      return new Matrix(0.0, pr, 0.0 - pr, 0.0, tx, ty);
    } else if (rotation == 2) {
      var tx = textureRectangle.right - sourceRectangle.left;
      var ty = textureRectangle.bottom - sourceRectangle.top;
      return new Matrix(0.0 - pr, 0.0, 0.0, 0.0 - pr, tx, ty);
    } else if (rotation == 3) {
      var tx = textureRectangle.left + sourceRectangle.top;
      var ty = textureRectangle.bottom - sourceRectangle.left;
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
      var tx = textureRectangle.left + sourceRectangle.left;
      var ty = textureRectangle.top + sourceRectangle.top;
      return new Matrix(sx * pr, 0.0, 0.0, sy * pr, sx * tx, sy * ty);
    } else if (rotation == 1) {
      var tx = textureRectangle.right - sourceRectangle.top;
      var ty = textureRectangle.top + sourceRectangle.left;
      return new Matrix(0.0, sy * pr, 0.0 - sx * pr, 0.0, sx * tx, sy * ty);
    } else if (rotation == 2) {
      var tx = textureRectangle.right - sourceRectangle.left;
      var ty = textureRectangle.bottom - sourceRectangle.top;
      return new Matrix(0.0 - sx * pr, 0.0, 0.0, 0.0 - sy * pr, sx * tx, sy * ty);
    } else if (rotation == 3) {
      var tx = textureRectangle.left + sourceRectangle.top;
      var ty = textureRectangle.bottom - sourceRectangle.left;
      return new Matrix(0.0, 0.0 - sy * pr, sx * pr, 0.0, sx * tx, sy * ty);
    } else {
      throw new Error();
    }
  }

  //---------------------------------------------------------------------------

  RenderTextureQuad clip(Rectangle<int> rectangle) {

    int tL = textureRectangle.left;
    int tT = textureRectangle.top;
    int tR = textureRectangle.right;
    int tB = textureRectangle.bottom;
    int sL = sourceRectangle.left;
    int sT = sourceRectangle.top;
    int sR = sourceRectangle.right;
    int sB = sourceRectangle.bottom;
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();

    int texL = tL;
    int texT = tT;
    int texR = tR;
    int texB = tB;
    int srcL = sL;
    int srcT = sT;

    if (rotation == 0) {
      texL = minInt(tR, maxInt(tL, tL + sL + rL));
      texT = minInt(tB, maxInt(tT, tT + sT + rT));
      texR = maxInt(tL, minInt(tR, tL + sL + rR));
      texB = maxInt(tT, minInt(tB, tT + sT + rB));
      srcL = sL - texL + tL;
      srcT = sT - texT + tT;
    } else if (rotation == 1) {
      texL = minInt(tR, maxInt(tL, tR - sT - rB));
      texT = minInt(tB, maxInt(tT, tT + sL + rL));
      texR = maxInt(tL, minInt(tR, tR - sT - rT));
      texB = maxInt(tT, minInt(tB, tT + sL + rR));
      srcL = sL - texT + tT;
      srcT = sT + texR - tR;
    } else if (rotation == 2) {
      texL = minInt(tR, maxInt(tL, tR - sL - rR));
      texT = minInt(tB, maxInt(tT, tB - sT - rB));
      texR = maxInt(tL, minInt(tR, tR - sL - rL));
      texB = maxInt(tT, minInt(tB, tB - sT - rT));
      srcL = sL + texR - tR;
      srcT = sT + texB - tB;
    } else if (rotation == 3) {
      texL = minInt(tR, maxInt(tL, tL + sT + rT));
      texT = minInt(tB, maxInt(tT, tB - sL - rR));
      texR = maxInt(tL, minInt(tR, tL + sT + rB));
      texB = maxInt(tT, minInt(tB, tB - sL - rL));
      srcL = sL + texB - tB;
      srcT = sT - texL + tL;
    }

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(texL, texT, texR - texL, texB - texT),
        new Rectangle<int>(srcL, srcT, sR - sL, sB - sT),
        rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  RenderTextureQuad cut(Rectangle<int> rectangle) {

    int tL = textureRectangle.left;
    int tT = textureRectangle.top;
    int tR = textureRectangle.right;
    int tB = textureRectangle.bottom;
    int sL = sourceRectangle.left;
    int sT = sourceRectangle.top;
    int rL = (rectangle.left * pixelRatio).round();
    int rT = (rectangle.top * pixelRatio).round();
    int rR = (rectangle.right * pixelRatio).round();
    int rB = (rectangle.bottom * pixelRatio).round();

    int texL = tL;
    int texT = tT;
    int texR = tR;
    int texB = tB;
    int srcL = sL;
    int srcT = sT;

    if (rotation == 0) {
      texL = minInt(tR, maxInt(tL, tL + sL + rL));
      texT = minInt(tB, maxInt(tT, tT + sT + rT));
      texR = maxInt(tL, minInt(tR, tL + sL + rR));
      texB = maxInt(tT, minInt(tB, tT + sT + rB));
      srcL = sL - texL + tL + rL;
      srcT = sT - texT + tT + rT;
    } else if (rotation == 1) {
      texL = minInt(tR, maxInt(tL, tR - sT - rB));
      texT = minInt(tB, maxInt(tT, tT - sL + rL));
      texR = maxInt(tL, minInt(tR, tR - sT - rT));
      texB = maxInt(tT, minInt(tB, tT - sL + rR));
      srcL = sL - texT + tT + rL;
      srcT = sT + texR - tR + rT;
    } else if (rotation == 2) {
      texL = minInt(tR, maxInt(tL, tR - sL - rR));
      texT = minInt(tB, maxInt(tT, tB - sT - rB));
      texR = maxInt(tL, minInt(tR, tR - sL - rL));
      texB = maxInt(tT, minInt(tB, tB - sT - rT));
      srcL = sL + texR - tR + rL;
      srcT = sT + texB - tB + rT;
    } else if (rotation == 3) {
      texL = minInt(tR, maxInt(tL, tL + sT + rT));
      texT = minInt(tB, maxInt(tT, tB - sL - rR));
      texR = maxInt(tL, minInt(tR, tL + sT + rB));
      texB = maxInt(tT, minInt(tB, tB - sL - rL));
      srcL = sL + texB - tB + rL;
      srcT = sT - texL + tL + rT;
    }

    return new RenderTextureQuad(renderTexture,
        new Rectangle<int>(texL, texT, texR - texL, texB - texT),
        new Rectangle<int>(srcL, srcT, rR - rL, rB - rT),
        rotation, pixelRatio);
  }

  //---------------------------------------------------------------------------

  ImageData createImageData() {
    var rect = textureRectangle;
    var context = renderTexture.canvas.context2D;
    return context.createImageData(rect.width, rect.height);
  }

  ImageData getImageData() {
    var rect = textureRectangle;
    var context = renderTexture.canvas.context2D;
    return context.getImageData(rect.left, rect.top, rect.width, rect.height);
  }

  void putImageData(ImageData imageData) {
    var rect = textureRectangle;
    var context = renderTexture.canvas.context2D;
    context.putImageData(imageData, rect.left, rect.top);
  }

}