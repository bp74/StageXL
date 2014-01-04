part of stagexl;

// TODO: rotated texture quads.

class RenderTextureQuad {

  RenderTexture _renderTexture;
  Float32List _uvList = new Float32List(8);

  int _offsetX = 0, _offsetY = 0;
  int _width = 0, _height = 0;
  int _x1 = 0, _y1 = 0;
  int _x3 = 0, _y3 = 0;
  int _rotation = 0;

  RenderTextureQuad(RenderTexture renderTexture, int x1, int y1, int x3, int y3) {

    _renderTexture = renderTexture;
    _x1 = x1; _y1 = y1;
    _x3 = x3; _y3 = y3;

    var renderTextureWidth = _renderTexture.width;
    var renderTextureHeight = _renderTexture.height;
    var dx = x3 - x1;
    var dy = y3 - y1;
    var x2 = 0, y2 = 0;
    var x4 = 0, y4 = 0;

    if (dx.sign == dy.sign) {
      x2 = x3; y2 = y1;
      x4 = x1; y4 = y3;
      _rotation = (dx > 0) ? 0 : 2;
      _width = dx.abs();
      _height = dy.abs();
    } else {
      x2 = x1; y2 = y3;
      x4 = x3; y4 = y1;
      _rotation = (dx > 0) ? 3 : 1;
      _width = dy.abs();
      _height = dx.abs();
    }

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
    renderTextureQuad._offsetX = offsetX;
    renderTextureQuad._offsetY = offsetY;

    return renderTextureQuad;
  }

}