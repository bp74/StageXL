part of stagexl;

// TODO: rotated texture quads.

class RenderTextureQuad {

  RenderTexture _renderTexture;

  int _offsetX = 0, _offsetY = 0;
  int _width = 0, _height = 0;
  int _x1 = 0, _y1 = 0;
  int _x3 = 0, _y3 = 0;
  int _rotation = 0;

  Float32List _uvList = new Float32List(8);

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
      _rotation = dx > 0 ? 0 : 2;
      _width = dx.abs();
      _height = dy.abs();
    } else {
      x2 = x1; y2 = y3;
      x4 = x3; y4 = y1;
      _rotation = dx < 0 ? 1 : 3;
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

  int get rotation => _rotation;

  int get width => _width;
  int get height => _height;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
}