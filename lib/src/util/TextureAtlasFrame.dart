part of stagexl;

class TextureAtlasFrame {

  final TextureAtlas _textureAtlas;  
  final String _name;
  final bool _rotated;
  
  final int _originalWidth;
  final int _originalHeight;
  final int _offsetX;
  final int _offsetY;
  
  final int _frameX;
  final int _frameY;
  final int _frameWidth;
  final int _frameHeight;

  TextureAtlasFrame.fromJson(TextureAtlas textureAtlas, String name, Map frame) :
    _textureAtlas = textureAtlas,
    _name = name,
    _rotated = frame["rotated"] as bool,
    _originalWidth = frame["sourceSize"]["w"] as int,
    _originalHeight = frame["sourceSize"]["h"] as int,
    _offsetX = frame["spriteSourceSize"]["x"] as int,
    _offsetY = frame["spriteSourceSize"]["y"] as int,
    _frameX = frame["frame"]["x"] as int,
    _frameY = frame["frame"]["y"] as int,
    _frameWidth = frame["frame"]["w"] as int,
    _frameHeight = frame["frame"]["h"] as int;     

  //-------------------------------------------------------------------------------------------------

  TextureAtlas get textureAtlas => _textureAtlas;
  String get name => _name;
  bool get rotated => _rotated;
  
  int get frameX => _frameX;
  int get frameY => _frameY;
  int get frameWidth => _frameWidth;
  int get frameHeight => _frameHeight;

  int get offsetX => _offsetX;
  int get offsetY => _offsetY;
  int get originalWidth => _originalWidth;
  int get originalHeight => _originalHeight;
}
