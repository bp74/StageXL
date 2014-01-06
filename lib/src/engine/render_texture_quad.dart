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

  RenderTextureQuad(RenderTexture renderTexture, int x1, int y1, int x3, int y3) {

    if (renderTexture is! RenderTexture) throw new ArgumentError();

    _renderTexture = renderTexture;
    _x1 = _ensureInt(x1);
    _y1 = _ensureInt(y1);
    _x3 = _ensureInt(x3);
    _y3 = _ensureInt(y3);

    int dx = x3 - x1;
    int dy = y3 - y1;
    bool horizontal = (dx.sign == dy.sign);

    _rotation = (dx > 0) ? (horizontal ? 0 : 3) : (horizontal ? 2 : 1);
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

  //-----------------------------------------------------------------------------------------------

  void setOffset(int offsetX, int offsetY) {
    _offsetX = _ensureInt(offsetX);
    _offsetY = _ensureInt(offsetY);
  }

  //-----------------------------------------------------------------------------------------------

  RenderTextureQuad clip(Rectangle clipRectangle) {

    num x1 = 0, y1 = 0, x3 = 0, y3 = 0;
    num offsetX = 0, offsetY = 0;

    if (_rotation == 0) {

      x1 = _x1 - _offsetX + max(_offsetX, clipRectangle.left);
      y1 = _y1 - _offsetY + max(_offsetY, clipRectangle.top);
      x3 = _x1 - _offsetX + min(_offsetX + _width, clipRectangle.right);
      y3 = _y1 - _offsetY + min(_offsetY + _height, clipRectangle.bottom);
      offsetX = _offsetX + x1 - _x1;
      offsetY = _offsetY + y1 - _y1;

    } else if (_rotation == 1) {

      x1 = _x1 + _offsetY - max(_offsetY, clipRectangle.top);
      y1 = _y1 - _offsetX + max(_offsetX, clipRectangle.left);
      x3 = _x1 + _offsetY - min(_offsetY + _height, clipRectangle.bottom);
      y3 = _y1 - _offsetX + min(_offsetX + _width, clipRectangle.right);
      offsetX = _offsetX + y1 - _y1;
      offsetY = _offsetY - x1 + _x1;

    }

    var renderTextureQuad = new RenderTextureQuad(_renderTexture, x1, y1, x3, y3);
    renderTextureQuad.setOffset(offsetX, offsetY);

    return renderTextureQuad;
  }

}