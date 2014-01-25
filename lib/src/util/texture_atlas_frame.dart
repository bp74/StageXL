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
    _rotated = _ensureBool(frame["rotated"]),
    _originalWidth = _ensureInt(frame["sourceSize"]["w"]),
    _originalHeight = _ensureInt(frame["sourceSize"]["h"]),
    _offsetX = _ensureInt(frame["spriteSourceSize"]["x"]),
    _offsetY = _ensureInt(frame["spriteSourceSize"]["y"]),
    _frameX = _ensureInt(frame["frame"]["x"]),
    _frameY = _ensureInt(frame["frame"]["y"]),
    _frameWidth = _ensureInt(frame["frame"]["w"]),
    _frameHeight = _ensureInt(frame["frame"]["h"]);

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

  //-------------------------------------------------------------------------------------------------

  BitmapData getBitmapData() {

    var renderTexture = _textureAtlas.renderTexture;
    var renderTextureQuad = new RenderTextureQuad(renderTexture,
        _rotated ? 1 : 0, _offsetX, _offsetY,
        _rotated ? _frameX + _frameHeight : _frameX, _frameY, _frameWidth, _frameHeight);

    return new BitmapData.fromRenderTextureQuad(renderTextureQuad, _originalWidth, _originalHeight);
  }

}
