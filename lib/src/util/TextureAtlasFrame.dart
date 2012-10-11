part of dartflash;

class TextureAtlasFrame
{
  String _name;
  TextureAtlas _textureAtlas;

  int _frameX;
  int _frameY;
  int _frameWidth;
  int _frameHeight;

  int _offsetX;
  int _offsetY;
  int _originalWidth;
  int _originalHeight;

  bool _rotated;

  TextureAtlasFrame(String name, TextureAtlas textureAtlas)
  {
    _name = name;
    _textureAtlas = textureAtlas;
  }

  //-------------------------------------------------------------------------------------------------

  TextureAtlas get textureAtlas => _textureAtlas;
  String get name => _name;

  int get frameX => _frameX;
  int get frameY => _frameY;
  int get frameWidth => _frameWidth;
  int get frameHeight => _frameHeight;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get originalWidth => _originalWidth;
  int get originalHeight => _originalHeight;

  bool get rotated => _rotated;
}
