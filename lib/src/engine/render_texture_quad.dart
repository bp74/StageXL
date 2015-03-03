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

    int x1 = 0, y1 = 0;
    int x2 = 0, y2 = 0;
    int x3 = 0, y3 = 0;
    int x4 = 0, y4 = 0;

    if (rotation == 0) {
      x1 = x4 = textureX;
      y1 = y2 = textureY;
      x2 = x3 = textureX + textureWidth;
      y3 = y4 = textureY + textureHeight;
    } else if (rotation == 1) {
      x1 = x2 = textureX;
      y1 = y4 = textureY;
      x3 = x4 = textureX - textureHeight;
      y2 = y3 = textureY + textureWidth;
    } else if (rotation == 2) {
      x1 = x4 = textureX;
      y1 = y2 = textureY;
      x2 = x3 = textureX - textureWidth;
      y3 = y4 = textureY - textureHeight;
    } else if (rotation == 3) {
      x1 = x2 = textureX;
      y1 = y4 = textureY;
      x3 = x4 = textureX + textureHeight;
      y2 = y3 = textureY - textureWidth;
    } else {
      throw new ArgumentError("rotation not supported.");
    }

    int renderTextureWidth = renderTexture.width;
    int renderTextureHeight = renderTexture.height;
    num storePixelRatio = renderTexture.storePixelRatio;

    uvList[0] = x1 / renderTextureWidth;
    uvList[1] = y1 / renderTextureHeight;
    uvList[2] = x2 / renderTextureWidth;
    uvList[3] = y2 / renderTextureHeight;
    uvList[4] = x3 / renderTextureWidth;
    uvList[5] = y3 / renderTextureHeight;
    uvList[6] = x4 / renderTextureWidth;
    uvList[7] = y4 / renderTextureHeight;

    xyList[0] = (x1 * storePixelRatio).round();
    xyList[1] = (y1 * storePixelRatio).round();
    xyList[2] = (x2 * storePixelRatio).round();
    xyList[3] = (y2 * storePixelRatio).round();
    xyList[4] = (x3 * storePixelRatio).round();
    xyList[5] = (y3 * storePixelRatio).round();
    xyList[6] = (x4 * storePixelRatio).round();
    xyList[7] = (y4 * storePixelRatio).round();
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to canvas coordinates.
   *
   * Canvas coordinates are in the range from (0, 0) to (width, height).
   */

  Matrix get drawMatrix {

    num s = renderTexture.storePixelRatio;

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

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to framebuffer coordinates.
   *
   * Framebuffer coordinates are in the range from (-1, -1) to (+1, +1).
   */

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

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to sampler coordinates.
   *
   * Sampler coordinate are in the range from (0, 0) to (1, 1).
   */

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

    num storePixelRatio = renderTexture.storePixelRatio;
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

    left = (left * storePixelRatio).round();
    top = (top * storePixelRatio).round();
    right = (right * storePixelRatio).round();
    bottom = (bottom * storePixelRatio).round();

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


}