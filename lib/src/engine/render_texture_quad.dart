part of stagexl;

class RenderTextureQuad {

  RenderTexture _renderTexture;

  // TODO: Use typed data once IE9 is no longer supported
  // Float32List _uvList = new Float32List(8);   // WebGL coordinates
  // Int32List _xyList = new Int32List(8);       // Canvas coordinates

  List<num> _uvList = [0, 0, 0, 0, 0, 0, 0, 0];   // WebGL coordinates
  List<int> _xyList = [0, 0, 0, 0, 0, 0, 0, 0];   // Canvas coordinates

  int _rotation = 0;
  int _offsetX = 0;
  int _offsetY = 0;
  int _textureX = 0;
  int _textureY = 0;
  int _textureWidth = 0;
  int _textureHeight = 0;

  RenderTextureQuad(RenderTexture renderTexture,
      int rotation, int offsetX, int offsetY,
      int textureX, int textureY, int textureWidth, int textureHeight) {

    _renderTexture = renderTexture;
    _rotation = _ensureInt(rotation);
    _offsetX = _ensureInt(offsetX);
    _offsetY = _ensureInt(offsetY);
    _textureX = _ensureInt(textureX);
    _textureY = _ensureInt(textureY);
    _textureWidth = _ensureInt(textureWidth);
    _textureHeight = _ensureInt(textureHeight);

    int x1 = 0, y1 = 0;
    int x2 = 0, y2 = 0;
    int x3 = 0, y3 = 0;
    int x4 = 0, y4 = 0;

    if (_rotation == 0) {
      x1 = x4 = _textureX;
      y1 = y2 = _textureY;
      x2 = x3 = _textureX + _textureWidth;
      y3 = y4 = _textureY + _textureHeight;
    } else if (_rotation == 1) {
      x1 = x2 = _textureX;
      y1 = y4 = _textureY;
      x3 = x4 = _textureX - _textureHeight;
      y2 = y3 = _textureY + _textureWidth;
    } else {
      throw new ArgumentError("rotation not supported.");
    }

    int renderTextureWidth = _renderTexture.width;
    int renderTextureHeight = _renderTexture.height;
    num storePixelRatio = _renderTexture.storePixelRatio;

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

  RenderTexture get renderTexture => _renderTexture;
  List<num> get uvList => _uvList;
  List<int> get xyList => _xyList;

  int get rotation => _rotation;
  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get textureX => _textureX;
  int get textureY => _textureY;
  int get textureWidth => _textureWidth;
  int get textureHeight => _textureHeight;

  //-----------------------------------------------------------------------------------------------

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to canvas coordinates.
   *
   * Canvas coordinates are in the range from (0, 0) to (width, height).
   */

  Matrix get drawMatrix {

    // var scale = _renderTexture.storePixelRatio;
    // var matrix = new Matrix.fromIdentity();
    // matrix.translate(-offsetX, -offsetY);
    // matrix.rotate(_rotation * PI / 2.0);
    // matrix.translate(textureX, textureY);
    // matrix.scale(scale, scale);
    // return matrix;

    num s = _renderTexture.storePixelRatio;

    return (_rotation == 0)
        ? new Matrix(s, 0.0, 0.0, s, s * (textureX - offsetX), s * (textureY - offsetY))
        : new Matrix(0.0, s, -s, 0.0, s * (textureX + offsetY), s * (textureY - offsetX));
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to framebuffer coordinates.
   *
   * Framebuffer coordinates are in the range from (-1, -1) to (+1, +1).
   */

  Matrix get bufferMatrix {

    // var scaleWidth = 2.0 / _renderTexture.width;
    // var scaleHeight = 2.0 / _renderTexture.height;
    // var matrix = new Matrix.fromIdentity();
    // matrix.translate(-offsetX, -offsetY);
    // matrix.rotate(_rotation * PI / 2.0);
    // matrix.translate(textureX, textureY);
    // matrix.scale(scaleWidth, scaleHeight);
    // matrix.translate(-1.0, -1.0);
    // return matrix;

    num sx = 2.0 / _renderTexture.width;
    num sy = 2.0 / _renderTexture.height;

    return (_rotation == 0)
        ? new Matrix(sx, 0.0, 0.0, sy, sx * (textureX - offsetX) - 1.0, sy * (textureY - offsetY) - 1.0)
        : new Matrix(0.0, sy, -sx, 0.0, sx * (textureX + offsetY) - 1.0, sy * (textureY - offsetX) - 1.0);
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * The matrix transformation for this RenderTextureQuad to
   * transform texture coordinates to sampler coordinates.
   *
   * Sampler coordinate are in the range from (0, 0) to (1, 1).
   */

  Matrix get samplerMatrix {

    num sx = 1.0 / _renderTexture.width;
    num sy = 1.0 / _renderTexture.height;

    return (_rotation == 0)
        ? new Matrix(sx, 0.0, 0.0, sy, sx * (textureX - offsetX), sy * (textureY - offsetY))
        : new Matrix(0.0, sy, -sx, 0.0, sx * (textureX + offsetY), sy * (textureY - offsetX));
  }

  //-----------------------------------------------------------------------------------------------

  int _minInt(int a, int b) => a < b ? a : b;
  int _maxInt(int a, int b) => a > b ? a : b;

  RenderTextureQuad clip(Rectangle<int> rectangle) {

    int left = _minInt(_offsetX + _textureWidth, _maxInt(_offsetX, rectangle.left));
    int top = _minInt(_offsetY + _textureHeight, _maxInt(_offsetY, rectangle.top));
    int right = _maxInt(_offsetX, _minInt(_offsetX + _textureWidth, rectangle.right));
    int bottom = _maxInt(_offsetY, _minInt(_offsetY + _textureHeight, rectangle.bottom));

    int textureX = rotation == 0 ? _textureX - _offsetX + left : _textureX + _offsetY - top;
    int textureY = rotation == 0 ? _textureY - _offsetY + top : _textureY - _offsetX + left;
    int textureWidth = right - left;
    int textureHeight = bottom - top;

    return new RenderTextureQuad(
        renderTexture, rotation, left, top, textureX, textureY, textureWidth, textureHeight);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad cut(Rectangle<int> rectangle) {
    var renderTextureQuad = clip(rectangle);
    renderTextureQuad._offsetX -= rectangle.left;
    renderTextureQuad._offsetY -= rectangle.top;
    return renderTextureQuad;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Rectangle<int> get _imageDataRectangle {
    num storePixelRatio = _renderTexture.storePixelRatio;
    int left = (rotation == 0) ? textureX : textureX - textureHeight;
    int top = (rotation == 0) ? textureY : textureY;
    int right = (rotation == 0) ? textureX + textureWidth : textureX;
    int bottom = (rotation == 0) ? textureY + textureHeight : textureY + textureWidth;

    left = (left * storePixelRatio).round();
    top = (top * storePixelRatio).round();
    right = (right * storePixelRatio).round();
    bottom = (bottom * storePixelRatio).round();

    return new Rectangle<int>(left, top, right - left, bottom - top);
  }

  ImageData createImageData() {
    var rectangle = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    return context.createImageData(rectangle.width, rectangle.height);
  }

  ImageData getImageData() {
    var rect = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    return context.getImageData(rect.left, rect.top, rect.width, rect.height);
  }

  void putImageData(ImageData imageData) {
    var rect = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    context.putImageData(imageData, rect.left, rect.top);
  }


}