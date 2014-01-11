part of stagexl;

class RenderTextureQuad {

  RenderTexture _renderTexture;
  Float32List _uvList = new Float32List(8);

  int _x1 = 0;
  int _y1 = 0;
  int _x3 = 0;
  int _y3 = 0;
  int _offsetX = 0;
  int _offsetY = 0;
  int _width = 0;
  int _height = 0;
  int _rotation = 0;

  RenderTextureQuad(RenderTexture renderTexture,
      int x1, int y1, int x3, int y3, int offsetX, int offsetY) {

    if (renderTexture is! RenderTexture) throw new ArgumentError();

    _renderTexture = renderTexture;
    _x1 = _ensureInt(x1);
    _y1 = _ensureInt(y1);
    _x3 = _ensureInt(x3);
    _y3 = _ensureInt(y3);
    _offsetX = _ensureInt(offsetX);
    _offsetY = _ensureInt(offsetY);

    int dx = x3 - x1;
    int dy = y3 - y1;
    bool horizontal = (dx.sign == dy.sign);

    _rotation = horizontal ? ((dx > 0) ? 0 : 2) : ((dx < 0) ? 1 : 3);
    _width = horizontal ? dx.abs() : dy.abs();
    _height = horizontal ? dy.abs() : dx.abs();

    int x2 = horizontal ? x3 : x1;
    int y2 = horizontal ? y1 : y3;
    int x4 = horizontal ? x1 : x3;
    int y4 = horizontal ? y3 : y1;
    int renderTextureWidth = _renderTexture.width;
    int renderTextureHeight = _renderTexture.height;

    uvList[0] = x1 / renderTextureWidth;
    uvList[1] = y1 / renderTextureHeight;
    uvList[2] = x2 / renderTextureWidth;
    uvList[3] = y2 / renderTextureHeight;
    uvList[4] = x3 / renderTextureWidth;
    uvList[5] = y3 / renderTextureHeight;
    uvList[6] = x4 / renderTextureWidth;
    uvList[7] = y4 / renderTextureHeight;
  }

  //-----------------------------------------------------------------------------------------------

  RenderTexture get renderTexture => _renderTexture;
  Float32List get uvList => _uvList;

  int get x1 => _x1;
  int get y1 => _y1;
  int get x3 => _x3;
  int get y3 => _y3;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get width => _width;
  int get height => _height;
  int get rotation => _rotation;

  Matrix get drawMatrix {
    num angle = _rotation * PI / 2.0;
    num cosR = cos(angle);
    num sinR = sin(angle);
    num tx = x1  - offsetX * cosR + offsetY * sinR;
    num ty = y1  - offsetX * sinR - offsetY * cosR;
    return new Matrix(cosR, sinR, - sinR, cosR, tx, ty);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad clip(Rectangle rectangle) {

    int x1 = 0, y1 = 0, x3 = 0, y3 = 0, offsetX = 0, offsetY = 0;

    if (_rotation == 0) {
      x1 = _x1 - _offsetX + max(_offsetX, rectangle.left);
      y1 = _y1 - _offsetY + max(_offsetY, rectangle.top);
      x3 = _x1 - _offsetX + min(_offsetX + _width, rectangle.right);
      y3 = _y1 - _offsetY + min(_offsetY + _height, rectangle.bottom);
      offsetX = _offsetX + x1 - _x1;
      offsetY = _offsetY + y1 - _y1;
    } else if (_rotation == 1) {
      x1 = _x1 + _offsetY - max(_offsetY, rectangle.top);
      y1 = _y1 - _offsetX + max(_offsetX, rectangle.left);
      x3 = _x1 + _offsetY - min(_offsetY + _height, rectangle.bottom);
      y3 = _y1 - _offsetX + min(_offsetX + _width, rectangle.right);
      offsetX = _offsetX + y1 - _y1;
      offsetY = _offsetY - x1 + _x1;
    }

    return new RenderTextureQuad(_renderTexture, x1, y1, x3, y3, offsetX, offsetY);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad cut(Rectangle rectangle) {
    var renderTextureQuad = clip(rectangle);
    renderTextureQuad._offsetX -= rectangle.x;
    renderTextureQuad._offsetY -= rectangle.y;
    return renderTextureQuad;
  }

}