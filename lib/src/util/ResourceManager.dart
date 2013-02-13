part of dartflash;

@deprecated
class Resource extends ResourceManager {

}

class ResourceManager
{
  Map<String, BitmapData> _images;
  Map<String, Sound> _sounds;
  Map<String, TextureAtlas> _textureAtlases;
  Map<String, String> _texts;

  Completer<ResourceManager> _loader;
  int _loaderPendingCount;
  int _loaderErrorCount;

  Resource()
  {
    _images = new Map<String, BitmapData>();
    _sounds = new Map<String, Sound>();
    _textureAtlases = new Map<String, TextureAtlas>();
    _texts = new Map<String, String>();

    _loader = null;
    _loaderPendingCount = 0;
    _loaderErrorCount = 0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void addImage(String name, String url)
  {
    _loaderPendingCount++;
    
    BitmapData.load(url).then((BitmapData bitmapData) {
      _images[name] = bitmapData;
      _loaderPendingCount--;
      _loaderCheck();
    }).catchError((AsyncError error) {
      _loaderErrorCount++;
      _loaderPendingCount--;
      _loaderCheck();
    });
  }

  void addSound(String name, String url)
  {
    _loaderPendingCount++;

    Sound.load(url).then((Sound sound) {
      _sounds[name] = sound;
      _loaderPendingCount--;
      _loaderCheck();
    }).catchError((AsyncError error) {
      _loaderErrorCount++;
      _loaderPendingCount--;
      _loaderCheck();
    });
  }

  void addTextureAtlas(String name, String url, String textureAtlasFormat)
  {
    _loaderPendingCount++;

    TextureAtlas.load(url, textureAtlasFormat).then((TextureAtlas textureAtlas) {
      _textureAtlases[name] = textureAtlas;
      _loaderPendingCount--;
      _loaderCheck();
    }).catchError((AsyncError error) {
      _loaderErrorCount++;
      _loaderPendingCount--;
      _loaderCheck();
    });
  }

  void addText(String name, String text)
  {
    _texts[name] = text;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Future<ResourceManager> load()
  {
    _loader = new Completer<ResourceManager>();
    _loaderCheck();

    return _loader.future;
  }

  BitmapData getBitmapData(String name)
  {
    if (_images.containsKey(name) == false)
      throw new ArgumentError("Resource not found: '$name'");

    return _images[name];
  }

  Sound getSound(String name)
  {
    if (_sounds.containsKey(name) == false)
      throw new ArgumentError("Resource not found: '$name'");

    return _sounds[name];
  }

  TextureAtlas getTextureAtlas(String name)
  {
    if (_textureAtlases.containsKey(name) == false)
      throw new ArgumentError("Resource not found: '$name'");

    return _textureAtlases[name];
  }

  String getText(String name)
  {
    if (_texts.containsKey(name) == false)
      return "[[$name]]";

    return _texts[name];
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _loaderCheck()
  {
    if (_loader != null && _loaderPendingCount == 0)
    {
      if (_loaderErrorCount == 0)
        _loader.complete(this);
      else
        _loader.completeError(new StateError("Error loading resources."));
    }
  }

}
