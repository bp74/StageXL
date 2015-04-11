part of stagexl.engine;

class RenderTextureQuad {

  final RenderTexture renderTexture;

  final int rotation;
  final int offsetX;
  final int offsetY;
  final int textureX;
  final int textureY;
  final int textureWidth;
  final int textureHeight;
  final num pixelRatio = 1.0;

  final Float32List uvList = new Float32List(8);   // WebGL coordinates
  final Int32List xyList = new Int32List(8);       // Canvas coordinates

  RenderTextureQuad(this.renderTexture,
      int rotation, int offsetX, int offsetY,
      int textureX, int textureY, int textureWidth, int textureHeight) :

    rotation = ensureInt(rotation),
    offsetX = ensureInt(offsetX),
    offsetY = ensureInt(offsetY),
    textureX = ensureInt(textureX),
    textureY = ensureInt(textureY),
    textureWidth = ensureInt(textureWidth),
    textureHeight = ensureInt(textureHeight) {

    if (rotation == 0) {
      xyList[0] = xyList[6] = textureX;
      xyList[1] = xyList[3] = textureY;
      xyList[2] = xyList[4] = textureX + textureWidth;
      xyList[5] = xyList[7] = textureY + textureHeight;
    } else if (rotation == 1) {
      xyList[0] = xyList[2] = textureX;
      xyList[1] = xyList[7] = textureY;
      xyList[4] = xyList[6] = textureX - textureHeight;
      xyList[3] = xyList[5] = textureY + textureWidth;
    } else if (rotation == 2) {
      xyList[0] = xyList[6] = textureX;
      xyList[1] = xyList[3] = textureY;
      xyList[2] = xyList[4] = textureX - textureWidth;
      xyList[5] = xyList[7] = textureY - textureHeight;
    } else if (rotation == 3) {
      xyList[0] = xyList[2] = textureX;
      xyList[1] = xyList[7] = textureY;
      xyList[4] = xyList[6] = textureX + textureHeight;
      xyList[3] = xyList[5] = textureY - textureWidth;
    } else {
      throw new ArgumentError("rotation not supported.");
    }

    uvList[0] = xyList[0] / renderTexture.width;
    uvList[1] = xyList[1] / renderTexture.height;
    uvList[2] = xyList[2] / renderTexture.width;
    uvList[3] = xyList[3] / renderTexture.height;
    uvList[4] = xyList[4] / renderTexture.width;
    uvList[5] = xyList[5] / renderTexture.height;
    uvList[6] = xyList[6] / renderTexture.width;
    uvList[7] = xyList[7] / renderTexture.height;
  }

  //-----------------------------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform texture coordinates to canvas coordinates.
  ///
  /// Canvas coordinates are in the range from (0, 0) to (width, height).

  Matrix get drawMatrix {

    num s = this.pixelRatio;

    if (rotation == 0) {
      return new Matrix( s, 0.0, 0.0,  s, s * (textureX - offsetX), s * (textureY - offsetY));
    } else if (rotation == 1) {
      return new Matrix(0.0,  s, -s, 0.0, s * (textureX + offsetY), s * (textureY - offsetX));
    } else if (rotation == 2) {
      return new Matrix(-s, 0.0, 0.0, -s, s * (textureX + offsetX), s * (textureY + offsetY));
    } else if (rotation == 3) {
      return new Matrix(0.0, -s,  s, 0.0, s * (textureX - offsetY), s * (textureY + offsetX));
    } else {
      throw new Error();
    }
  }

  //-----------------------------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform texture coordinates to framebuffer coordinates.
  ///
  /// Framebuffer coordinates are in the range from (-1, -1) to (+1, +1).

  Matrix get bufferMatrix {

    num sx = 2.0 / renderTexture.width;
    num sy = 2.0 / renderTexture.height;

    if (rotation == 0) {
      return new Matrix( sx, 0.0, 0.0,  sy, sx * (textureX - offsetX) - 1.0, sy * (textureY - offsetY) - 1.0);
    } else if (rotation == 1) {
      return new Matrix(0.0,  sy, -sx, 0.0, sx * (textureX + offsetY) - 1.0, sy * (textureY - offsetX) - 1.0);
    } else if (rotation == 2) {
      return new Matrix(-sx, 0.0, 0.0, -sy, sx * (textureX + offsetX) - 1.0, sy * (textureY + offsetY) - 1.0);
    } else if (rotation == 3) {
      return new Matrix(0.0, -sy,  sx, 0.0, sx * (textureX - offsetY) - 1.0, sy * (textureY + offsetX) - 1.0);
    } else {
      throw new Error();
    }
  }

  //-----------------------------------------------------------------------------------------------

  /// The matrix transformation for this RenderTextureQuad to
  /// transform texture coordinates to sampler coordinates.
  ///
  /// Sampler coordinate are in the range from (0, 0) to (1, 1).

  Matrix get samplerMatrix {

    num sx = 1.0 / renderTexture.width;
    num sy = 1.0 / renderTexture.height;

    if (rotation == 0) {
      return new Matrix( sx, 0.0, 0.0,  sy, sx * (textureX - offsetX), sy * (textureY - offsetY));
    } else if (rotation == 1) {
      return new Matrix(0.0,  sy, -sx, 0.0, sx * (textureX + offsetY), sy * (textureY - offsetX));
    } else if (rotation == 2) {
      return new Matrix(-sx, 0.0, 0.0, -sy, sx * (textureX + offsetX), sy * (textureY + offsetY));
    } else if (rotation == 3) {
      return new Matrix(0.0, -sy,  sx, 0.0, sx * (textureX - offsetY), sy * (textureY + offsetX));
    } else {
      throw new Error();
    }
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad clip(Rectangle<int> rectangle) {

    int left = minInt(offsetX + textureWidth, maxInt(offsetX, rectangle.left));
    int top = minInt(offsetY + textureHeight, maxInt(offsetY, rectangle.top));
    int right = maxInt(offsetX, minInt(offsetX + textureWidth, rectangle.right));
    int bottom = maxInt(offsetY, minInt(offsetY + textureHeight, rectangle.bottom));

    int clipTextureX = 0;
    int clipTextureY = 0;
    int clipTextureWidth = right - left;
    int clipTextureHeight = bottom - top;
    int clipOffsetX = left;
    int clipOffsetY = top;

    if (rotation == 0) {
      clipTextureX = textureX - offsetX + left;
      clipTextureY = textureY - offsetY + top;
    } else if (rotation == 1) {
      clipTextureX = textureX + offsetY - top;
      clipTextureY = textureY - offsetX + left;
    } else if (rotation == 2) {
      clipTextureX = textureX + offsetX - left;
      clipTextureY = textureY + offsetY - top;
    } else if (rotation == 3) {
      clipTextureX = textureX - offsetY + top;
      clipTextureY = textureY + offsetX - left;
    }

    return new RenderTextureQuad(
        renderTexture, rotation, clipOffsetX, clipOffsetY,
        clipTextureX, clipTextureY, clipTextureWidth, clipTextureHeight);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad cut(Rectangle<int> rectangle) {

    int left = minInt(offsetX + textureWidth, maxInt(offsetX, rectangle.left));
    int top = minInt(offsetY + textureHeight, maxInt(offsetY, rectangle.top));
    int right = maxInt(offsetX, minInt(offsetX + textureWidth, rectangle.right));
    int bottom = maxInt(offsetY, minInt(offsetY + textureHeight, rectangle.bottom));

    int cutTextureX = 0;
    int cutTextureY = 0;
    int cutTextureWidth = right - left;
    int cutTextureHeight = bottom - top;
    int cutOffsetX = left - rectangle.left;
    int cutOffsetY = top - rectangle.top;

    if (rotation == 0) {
      cutTextureX = textureX - offsetX + left;
      cutTextureY = textureY - offsetY + top;
    } else if (rotation == 1) {
      cutTextureX = textureX + offsetY - top;
      cutTextureY = textureY - offsetX + left;
    } else if (rotation == 2) {
      cutTextureX = textureX + offsetX - left;
      cutTextureY = textureY + offsetY - top;
    } else if (rotation == 3) {
      cutTextureX = textureX - offsetY + top;
      cutTextureY = textureY + offsetX - left;
    }

    return new RenderTextureQuad(
        renderTexture, rotation, cutOffsetX, cutOffsetY,
        cutTextureX, cutTextureY, cutTextureWidth, cutTextureHeight);
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Rectangle<int> _getImageDataRectangle() {

    num pixelRatio = this.pixelRatio;
    int left = 0, top = 0, right = 1, bottom = 1;

    if (rotation == 0) {
      left = textureX;
      top = textureY;
      right = textureX + textureWidth;
      bottom = textureY + textureHeight;
    } else if (rotation == 1) {
      left = textureX - textureHeight;
      top = textureY;
      right = textureX;
      bottom = textureY + textureWidth;
    } else if (rotation == 2) {
      left = textureX - textureWidth;
      top = textureY - textureHeight;
      right = textureX;
      bottom = textureY;
    } else if (rotation == 3) {
      left = textureX;
      top = textureY - textureWidth;
      right = textureX + textureHeight;
      bottom = textureY;
    }

    left = (left * pixelRatio).round();
    top = (top * pixelRatio).round();
    right = (right * pixelRatio).round();
    bottom = (bottom * pixelRatio).round();

    return new Rectangle<int>(left, top, right - left, bottom - top);
  }

  ImageData createImageData() {
    var rectangle = _getImageDataRectangle();
    var context = renderTexture.canvas.context2D;
    return context.createImageData(rectangle.width, rectangle.height);
  }

  ImageData getImageData() {
    var rect = _getImageDataRectangle();
    var context = renderTexture.canvas.context2D;
    return context.getImageData(rect.left, rect.top, rect.width, rect.height);
  }

  void putImageData(ImageData imageData) {
    var rect = _getImageDataRectangle();
    var context = renderTexture.canvas.context2D;
    context.putImageData(imageData, rect.left, rect.top);
  }

  RenderTextureQuad withPixelRatio(num pixelRatio) {
    // TODO: Fix pixelRatio
    return this;
  }

}