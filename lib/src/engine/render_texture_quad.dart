part of stagexl;

class RenderTextureQuad {

  RenderTexture _renderTexture;
  Float32List _uvList = new Float32List(8);   // WebGL coordinates
  Int32List _xyList = new Int32List(8);       // Canvas coordinates

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
    num pixelRatio = _renderTexture.storePixelRatio / _backingStorePixelRatio;

    uvList[0] = x1 / renderTextureWidth;
    uvList[1] = y1 / renderTextureHeight;
    uvList[2] = x2 / renderTextureWidth;
    uvList[3] = y2 / renderTextureHeight;
    uvList[4] = x3 / renderTextureWidth;
    uvList[5] = y3 / renderTextureHeight;
    uvList[6] = x4 / renderTextureWidth;
    uvList[7] = y4 / renderTextureHeight;

    xyList[0] = (x1 * pixelRatio).round();
    xyList[1] = (y1 * pixelRatio).round();
    xyList[2] = (x2 * pixelRatio).round();
    xyList[3] = (y2 * pixelRatio).round();
    xyList[4] = (x3 * pixelRatio).round();
    xyList[5] = (y3 * pixelRatio).round();
    xyList[6] = (x4 * pixelRatio).round();
    xyList[7] = (y4 * pixelRatio).round();
  }

  //-----------------------------------------------------------------------------------------------

  RenderTexture get renderTexture => _renderTexture;
  Float32List get uvList => _uvList;
  Int32List get xyList => _xyList;

  int get rotation => _rotation;
  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get textureX => _textureX;
  int get textureY => _textureY;
  int get textureWidth => _textureWidth;
  int get textureHeight => _textureHeight;

  Matrix get drawMatrix {
    /*
    var scale = _renderTexture.storePixelRatio / _backingStorePixelRatio;
    var matrix = new Matrix.fromIdentity();
    matrix.translate(-offsetX, -offsetY);
    matrix.rotate(_rotation * PI / 2.0);
    matrix.translate(x1, y1);
    matrix.scale(scale, scale);
    return matrix;
    */
    num scale = _renderTexture.storePixelRatio / _backingStorePixelRatio;
    num angle = _rotation * PI / 2.0;
    num c = scale * cos(angle);
    num s = scale * sin(angle);
    num tx = scale * textureX  - offsetX * c + offsetY * s;
    num ty = scale * textureY  - offsetX * s - offsetY * c;
    return new Matrix(c, s, -s, c, tx, ty);
  }

  //-----------------------------------------------------------------------------------------------

  int _minInt(int a, int b) => a < b ? a : b;
  int _maxInt(int a, int b) => a > b ? a : b;

  RenderTextureQuad clip(Rectangle rectangle) {

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

  RenderTextureQuad cut(Rectangle rectangle) {
    var renderTextureQuad = clip(rectangle);
    renderTextureQuad._offsetX -= rectangle.x;
    renderTextureQuad._offsetY -= rectangle.y;
    return renderTextureQuad;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Rectangle get _imageDataRectangle {
    num storePixelRatio = _renderTexture.storePixelRatio;
    num backingStorePixelRatio = _backingStorePixelRatio;
    num pixelRatio = storePixelRatio / backingStorePixelRatio;
    int left = (rotation == 0) ? textureX : textureX - textureHeight;
    int top = (rotation == 0) ? textureY : textureY;
    int right = (rotation == 0) ? textureX + textureWidth : textureX;
    int bottom = (rotation == 0) ? textureY + textureHeight : textureY + textureWidth;

    left = (left * pixelRatio).round();
    top = (top * pixelRatio).round();
    right = (right * pixelRatio).round();
    bottom = (bottom * pixelRatio).round();

    return new Rectangle(left, top, right - left, bottom - top);
  }

  ImageData createImageData() {
    var rectangle = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    return context.createImageData(rectangle.width, rectangle.height);
  }

  ImageData getImageData() {
    var rect = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    var backingStorePixelRatio = _backingStorePixelRatio;
    if (backingStorePixelRatio > 1.0) {
      return context.getImageDataHD(rect.x, rect.y, rect.width, rect.height);
    } else {
      return context.getImageData(rect.x, rect.y, rect.width, rect.height);
    }
  }

  void putImageData(ImageData imageData) {
    var rect = _imageDataRectangle;
    var context = _renderTexture.canvas.context2D;
    var backingStorePixelRatio = _backingStorePixelRatio;
    if (backingStorePixelRatio > 1.0) {
      context.putImageDataHD(imageData, rect.x, rect.y);
    } else {
      context.putImageData(imageData, rect.x, rect.y);
    }
  }


}