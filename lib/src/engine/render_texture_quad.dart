part of stagexl;

// TODO: rotated texture quads.

class RenderTextureQuad {

  RenderTexture _renderTexture;
  int _width = 0, _height = 0;
  int _x1 = 0, _y1 = 0, _x2 = 0, _y2 = 0;
  num _u1 = 0.0, _v1 = 0.0, _u2 = 0.0, _v2 = 0.0;

  int _offsetX = 0, _offsetY = 0;

  RenderTextureQuad(RenderTexture renderTexture, int x1, int y1, int x2, int y2) {

    _renderTexture = renderTexture;

    _x1 = x1;
    _y1 = y1;
    _x2 = x2;
    _y2 = y2;

    _u1 = x1 / renderTexture.width;
    _v1 = y1 / renderTexture.height;
    _u2 = x2 / renderTexture.width;
    _v2 = y2 / renderTexture.height;

    _width = _x2 - _x1;
    _height = _y2 - _y1;
  }

  //-----------------------------------------------------------------------------------------------

  RenderTexture get renderTexture => _renderTexture;

  int get x1 => _x1;
  int get y1 => _y1;
  int get x2 => _x2;
  int get y2 => _y2;

  num get u1 => _u1;
  num get v1 => _v1;
  num get u2 => _u2;
  num get v2 => _v2;

  int get width => _width;
  int get height => _height;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
}