part of dartflash;

// Flump converts Flash keyframe animations into texture atlases and JSON that 
// can be easily integrated into any scene graph-based 2D game engine.
// 
// http://threerings.github.com/flump/

class FlumpLibrary 
{
  String _url;
  String _md5;
  int _frameRate;
  List<_FlumpMovie> _movies;
  List<_FlumpTextureGroup> _textureGroups;
  
  static Future<FlumpLibrary> load(String url)
  {
    var completer = new Completer<FlumpLibrary>();
  
    void onLoad(event) {
      var data = json.parse(event.target.responseText) as Map;
      var textureGroupLoaders = new List();
      var flumpLibrary = new FlumpLibrary();
      
      flumpLibrary._url = url;
      flumpLibrary._md5 = data["md5"];
      flumpLibrary._frameRate = data["frameRate"].toInt();
      flumpLibrary._movies = new List<_FlumpMovie>();
      flumpLibrary._textureGroups = new List<_FlumpTextureGroup>();

      for(var movieJson in data["movies"] as List) {
        var flumpMovie = new _FlumpMovie(movieJson, flumpLibrary);
        flumpLibrary._movies.add(flumpMovie);
      }
      
      for(var textureGroupJson in data["textureGroups"] as List) {
        var flumpTextureGroup = new _FlumpTextureGroup(textureGroupJson, flumpLibrary);
        flumpLibrary._textureGroups.add(flumpTextureGroup);
        textureGroupLoaders.add(flumpTextureGroup.completer.future);
      }
      
      Future.wait(textureGroupLoaders)
        .then((value) => completer.complete(flumpLibrary))
        .catchError((error) => completer.completeError(new StateError("Failed to load image.")));
    }
    
    void onError(event) {
      completer.completeError(new StateError("Failed to load json file."));
    }

    var request = new HttpRequest()
      ..onLoad.listen(onLoad)
      ..onError.listen(onError)
      ..open('GET', url, true)          
      ..send();

    return completer.future;
  }
  
  FlumpMovie CreateFlumpMovie(String name) {
    return new FlumpMovie(this, name);
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class FlumpMovie extends DisplayObject implements Animatable
{
  FlumpMovie(FlumpLibrary flumpLibrary, String name) {
    
  }
  
  bool advanceTime(num time) {
    
    return true;   
  }
  
  void render(RenderState renderState) {
    
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpMovie
{
  FlumpLibrary flumpLibrary;
  String id; 
  List<_FlumpLayer> layers;
  
  _FlumpMovie(Map json, this.flumpLibrary) {
    this.id = json["id"];
    this.layers = new List<_FlumpLayer>();
    
    for(var layer in json["layers"]) {
      this.layers.add(new _FlumpLayer(layer));
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpLayer 
{
  String name;
  List<_FlumpKeyframe> keyframes;
  
  _FlumpLayer(Map json) {
    this.name = json["name"];
    this.keyframes = new List<_FlumpKeyframe>();
    
    for(var keyframe in json["keyframes"]) {
      this.keyframes.add(new _FlumpKeyframe(keyframe));
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpKeyframe
{
  int index;
  int duration;
  String ref;           
  String label;
  
  num x, y;
  num scaleX, scaleY;
  num skewX, skewY;
  num pivotX, pivotY;
  
  bool visible;
  num alpha;
  
  bool tweened;
  num ease;
  
  _FlumpKeyframe(Map json) {
    this.index = json["index"];
    this.duration = json["duration"];
    
    this.ref = json.containsKey("ref") ? json["ref"] : null;
    this.label = json.containsKey("label") ? json["label"] : null;
    
    this.x = json.containsKey("loc") ? json["loc"][0] : 0.0;
    this.y = json.containsKey("loc") ? json["loc"][1] : 0.0;
    this.scaleX = json.containsKey("scale") ? json["scale"][0] : 1.0;
    this.scaleY = json.containsKey("scale") ? json["scale"][1] : 1.0;
    this.skewX = json.containsKey("skew") ? json["skew"][0] : 0.0;
    this.skewY = json.containsKey("skew") ? json["skew"][1] : 0.0;
    this.pivotX = json.containsKey("pivot") ? json["pivot"][0] : 0.0;
    this.pivotY = json.containsKey("pivot") ? json["pivot"][1] : 0.0;
    
    this.visible = json.containsKey("visible") ? json["visible"] : true;
    this.alpha = json.containsKey("alpha") ? json["alpha"] : 1.0;
    
    this.tweened = json.containsKey("tweened") ? json["tweened"] : true;
    this.ease = json.containsKey("ease") ? json["ease"] : 0.0;
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpTextureGroup
{
  FlumpLibrary flumpLibrary;
  Map<String, _FlumpTexture> flumpTextures;
  Completer completer;
  
  _FlumpTextureGroup(Map json, this.flumpLibrary) {
    
    this.flumpTextures = new Map<String, _FlumpTexture>(); 
    this.completer = new Completer();
        
    var imageLoadCount = 0;
    
    for(var atlas in json["atlases"] as List) {
      var file = atlas["file"] as String;
      var url = _replaceFilename(flumpLibrary._url, file);
      
      imageLoadCount++;
      
      var imageElement = new ImageElement();
      
      imageElement.onLoad.listen((event) {
        if (--imageLoadCount == 0) 
          this.completer.complete(this);
      });
      
      imageElement.onError.listen((event) {
        this.completer.completeError(new StateError("Failed to load image."));
      });
      
      imageElement.src = url;
      
      for(var texture in atlas["textures"] as List) {
        var symbol = texture["symbol"] as String;
        var rect = texture["rect"] as List;
        var origin = texture["origin"] as List;
          
        var flumpTexture = new _FlumpTexture(
          rect[0], rect[1],rect[2], rect[3], 
          origin[0], origin[1],
          imageElement);
          
        this.flumpTextures[symbol] = flumpTexture;
      }
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpTexture {
  num x, y, width, height;
  num originX, originY;
  ImageElement imageElement;
  
  _FlumpTexture(this.x, this.y, this.width, this.height, this.originX, this.originY, this.imageElement);
}

