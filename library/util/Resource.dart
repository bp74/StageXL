class Resource 
{
  Map<String, BitmapData> _images;
  Map<String, Sound> _sounds;
  Map<String, TextureAtlas> _textureAtlases;
  Map<String, String> _texts;
  
  Completer<Resource> _loader;
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
    Future<BitmapData> future = BitmapData.loadImage(url);
    _loaderPendingCount++;
    
    future.then((BitmapData bitmapData) 
    {
      _images[name] = bitmapData;
      _loaderPendingCount--;
      _loaderCheck();
    });
    
    future.handleException((e)
    {
      _loaderErrorCount++;
      _loaderPendingCount--;
      _loaderCheck();
    });
  }
  
  void addSound(String name, String url) 
  {
    Future<Sound> future = Sound.loadAudio(url);
    _loaderPendingCount++;
    
    future.then((Sound sound) 
    {
      _sounds[name] = sound;
      _loaderPendingCount--;
      _loaderCheck();
    });
    
    future.handleException((e) 
    {
      _loaderErrorCount++;
      _loaderPendingCount--;
      _loaderCheck();
    });
  }
  
  void addTextureAtlas(String name, String url, String textureAtlasFormat)
  {
    Future<TextureAtlas> future = TextureAtlas.load(url, textureAtlasFormat);
    _loaderPendingCount++;
    
    future.then((TextureAtlas textureAtlas) 
    {
      _textureAtlases[name] = textureAtlas;
      _loaderPendingCount--;
      _loaderCheck();
    });
    
    future.handleException((e)
    {
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

  Future<Resource> load() 
  {
    _loader = new Completer<Resource>(); 
    _loaderCheck();
    
    return _loader.future;
  }
  
  BitmapData getBitmapData(String name) 
  {
    if (_images.containsKey(name) == false) 
      throw "Resource not found: '$name'";
    
    return _images[name];
  }
  
  Sound getSound(String name) 
  {
    if (_sounds.containsKey(name) == false) 
      throw "Resource not found: '$name'";
    
    return _sounds[name];
  }
  
  TextureAtlas getTextureAtlas(String name) 
  {
    if (_textureAtlases.containsKey(name) == false) 
      throw "Resource not found: '$name'";
    
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
        _loader.completeException(this);
    }
  }
  
}
