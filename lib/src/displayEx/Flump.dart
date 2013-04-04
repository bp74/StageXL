part of stagexl;

// Flump converts Flash keyframe animations into texture atlases and JSON.
// http://threerings.github.com/flump/

class FlumpLibrary {
  
  String _url;
  String _md5;
  int _frameRate;
  final List<_FlumpMovieData> _movieDatas = new List<_FlumpMovieData>();
  final List<_FlumpTextureGroup> _textureGroups = new List<_FlumpTextureGroup>();
  
  static Future<FlumpLibrary> load(String url) {
    
    var completer = new Completer<FlumpLibrary>();
  
    HttpRequest.getString(url).then((flumpJson) {
      
      var data = json.parse(flumpJson) as Map;
      var textureGroupLoaders = new List();
      var flumpLibrary = new FlumpLibrary();
      
      flumpLibrary._url = url;
      flumpLibrary._md5 = data["md5"];
      flumpLibrary._frameRate = data["frameRate"].toInt();

      for(var movieJson in data["movies"] as List) {
        var flumpMovieData = new _FlumpMovieData(movieJson, flumpLibrary);
        flumpLibrary._movieDatas.add(flumpMovieData);
      }
      
      for(var textureGroupJson in data["textureGroups"] as List) {
        var flumpTextureGroup = new _FlumpTextureGroup(textureGroupJson, flumpLibrary);
        flumpLibrary._textureGroups.add(flumpTextureGroup);
        textureGroupLoaders.add(flumpTextureGroup.completer.future);
      }
      
      Future.wait(textureGroupLoaders).then((value) {
        completer.complete(flumpLibrary);
      }).catchError((error) {
        completer.completeError(new StateError("Failed to load image."));
      });
      
    }).catchError((error) {

      completer.completeError(new StateError("Failed to load json file."));
      
    });

    return completer.future;
  }
  
  _FlumpMovieData _getFlumpMovieData(String name) {
    for(var movie in _movieDatas)
      if (movie.id == name)
        return movie;
        
    throw new ArgumentError("The movie '$name' is not available.");
  }
  
  BitmapDrawable _createSymbol(String name) {
    for(var textureGroup in _textureGroups) {
      if (textureGroup.flumpTextures.containsKey(name)) {
        return textureGroup.flumpTextures[name];        
      }
    }
    
    for(var movieData in _movieDatas) {
      if (movieData.id == name) {
        return new FlumpMovie(this, name);
      }
    }
    
    throw new ArgumentError("The symbol '$name' is not available.");
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class FlumpMovie extends DisplayObject implements Animatable {
  
  final FlumpLibrary _flumpLibrary;
  final _FlumpMovieData _flumpMovieData;
  final List<_FlumpMovieLayer> _flumpMovieLayers = new List<_FlumpMovieLayer>();
  
  num _time = 0.0;
  num _duration = 0.0;
  int _frame = 0;
  int _frames = 0;
  
  // ToDo: add features like playOnce, playTo, goTo, loop, stop, isPlaying, label events, ...

  FlumpMovie(FlumpLibrary flumpLibrary, String name) :
    _flumpLibrary = flumpLibrary,
    _flumpMovieData = flumpLibrary._getFlumpMovieData(name) {
    
    for(var flumpLayerData in _flumpMovieData.flumpLayerDatas) {
      var flashMovieLayer = new _FlumpMovieLayer(_flumpLibrary, flumpLayerData);
      _flumpMovieLayers.add(flashMovieLayer);
    }
    
    _frames = _flumpMovieData.frames;
    _duration = _frames / _flumpLibrary._frameRate;
  }
  
  bool advanceTime(num time) {
    _time += time;

    var frameTime = _time % _duration;
    _frame = min((_frames * frameTime / _duration).toInt(), _frames - 1);
    
    for(var flumpMovieLayer in _flumpMovieLayers) {
      flumpMovieLayer.advanceTime(time);
      flumpMovieLayer.setFrame(_frame);
    }
    
    return true;   
  }
 
  void render(RenderState renderState) {
    for(var flumpMovieLayer in _flumpMovieLayers) {
      if (flumpMovieLayer.visible) {
        renderState.renderDisplayObject(flumpMovieLayer);
      }
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpMovieLayer extends DisplayObject implements Animatable {
  
  final FlumpLibrary flumpLibrary;
  final _FlumpLayerData flumpLayerData;
  final Map<String, BitmapDrawable> symbols = new Map<String, BitmapDrawable>();
  BitmapDrawable symbol;
  
  _FlumpMovieLayer(FlumpLibrary flumpLibrary, _FlumpLayerData flumpLayerData) :
    this.flumpLibrary = flumpLibrary,
    this.flumpLayerData = flumpLayerData {
    
    for(var keyframe in flumpLayerData.flumpKeyframeDatas) {
      if (keyframe.ref != null && symbols.containsKey(keyframe.ref) == false) {
        symbols[keyframe.ref] = flumpLibrary._createSymbol(keyframe.ref);
      }
    }
    
    setFrame(0);
  }
  
  bool advanceTime(num time) {
    if (symbol is Animatable) {
      var animatable = symbol as Animatable;
      animatable.advanceTime(time);
    }
  }
  
  void setFrame(int frame) {
    var keyframe = flumpLayerData.getKeyframeForFrame(frame);
    
    num x = keyframe.x, y = keyframe.y;
    num scaleX = keyframe.scaleX, scaleY = keyframe.scaleY;
    num skewX = keyframe.skewX, skewY = keyframe.skewY;
    num pivotX = keyframe.pivotX, pivotY = keyframe.pivotY;
    num alpha = keyframe.alpha;
    
    if (keyframe.index != frame && keyframe.tweened) {
      var nextKeyframe = flumpLayerData.getKeyframeAfter(keyframe);
      
      if (nextKeyframe != null) {
        var interped = (frame - keyframe.index) / keyframe.duration;
        var ease = keyframe.ease;
        
        if (ease != 0) {
          var t = 0.0;
          if (ease < 0) {
            var inv = 1 - interped;
            t = 1 - inv * inv;
            ease = 0 - ease;
          } else {
            t = interped * interped;
          }
          interped = ease * t + (1 - ease) * interped;
        }
        
        x = x + (nextKeyframe.x - x) * interped;
        y = y + (nextKeyframe.y - y) * interped;
        scaleX = scaleX + (nextKeyframe.scaleX - scaleX) * interped;
        scaleY = scaleY + (nextKeyframe.scaleY - scaleY) * interped;
        skewX = skewX + (nextKeyframe.skewX - skewX) * interped;
        skewY = skewY + (nextKeyframe.skewY - skewY) * interped;
        alpha = alpha + (nextKeyframe.alpha - alpha) * interped;
      }
    }
    
    /*
    _transformationMatrixPrivate.identity();
    _transformationMatrixPrivate.translate(-pivotX, -pivotY);
    _transformationMatrixPrivate.scale(scaleX, scaleY);
    _transformationMatrixPrivate.skew(skewX, skewY);
    _transformationMatrixPrivate.translate(x, y);
    */
    
    num a =   scaleX * cos(skewY);
    num b =   scaleX * sin(skewY);
    num c = - scaleY * sin(skewX);
    num d =   scaleY * cos(skewX);
    num tx =  x - (pivotX * a + pivotY * c);
    num ty =  y - (pivotX * b + pivotY * d);

    _transformationMatrixRefresh = false;
    _transformationMatrixPrivate.setTo(a, b, c, d, tx, ty);
    
    _alpha = alpha;
    _visible = keyframe.visible;
    
    symbol = (keyframe.ref != null) ? symbols[keyframe.ref] : null;
  }
  
  void render(RenderState renderState) {
    if (symbol != null) {
      symbol.render(renderState);
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpMovieData {
  
  final String id;
  final FlumpLibrary flumpLibrary;
  final List<_FlumpLayerData> flumpLayerDatas = new List<_FlumpLayerData>();
  
  _FlumpMovieData(Map json, FlumpLibrary flumpLibrary) :
    flumpLibrary = flumpLibrary,
    id = json["id"] {
                                                                  
    for(var layer in json["layers"]) {
      var flumpLayerData = new _FlumpLayerData(layer);
      this.flumpLayerDatas.add(flumpLayerData);
    }
  }
  
  int get frames {
    var frames = 0;
    for(var flumpLayerData in flumpLayerDatas) 
      frames = max(frames, flumpLayerData.frames);
        
    return frames;
  }  
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpLayerData {
  
  final String name;
  final bool flipbook;
  final List<_FlumpKeyframeData> flumpKeyframeDatas = new List<_FlumpKeyframeData>();
  
  _FlumpLayerData(Map json) : 
    this.name = json["name"],
    this.flipbook = json.containsKey("flipbook") ? json["flipbook"] : false {
      
    for(var keyframe in json["keyframes"]) {
      var flumpKeyframeData = new _FlumpKeyframeData(keyframe);
      this.flumpKeyframeDatas.add(flumpKeyframeData);
    }
  }
  
  int get frames {
    var flumpKeyframeData = flumpKeyframeDatas[flumpKeyframeDatas.length - 1];
    return flumpKeyframeData.index + flumpKeyframeData.duration;
  }  
  
  _FlumpKeyframeData getKeyframeForFrame(int frame) {
    var i  = 1;
    while(i < flumpKeyframeDatas.length && flumpKeyframeDatas[i].index <= frame) i++;
    return flumpKeyframeDatas[i - 1];
  }
  
  _FlumpKeyframeData getKeyframeAfter(_FlumpKeyframeData flumpKeyframeData) {
    for(int i = 0; i < flumpKeyframeDatas.length - 1; i++)
      if (identical(flumpKeyframeDatas[i], flumpKeyframeData))
        return flumpKeyframeDatas[i + 1];
    
    return null;
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpKeyframeData {
  
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
  
  _FlumpKeyframeData(Map json) {
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

class _FlumpTextureGroup {
  
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
          rect[0], rect[1], rect[2], rect[3], 
          origin[0], origin[1],
          imageElement);
          
        this.flumpTextures[symbol] = flumpTexture;
      }
    }
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

class _FlumpTexture implements BitmapDrawable {
  
  num x, y, width, height;
  num originX, originY;
  ImageElement imageElement;
  html.Rect _sourceRect;
  html.Rect _destinationRect;
  
  _FlumpTexture(this.x, this.y, this.width, this.height, this.originX, this.originY, this.imageElement);
  
  void render(RenderState renderState) {
    renderState.context.drawImageScaledFromSource(imageElement, x, y, width, height, 0, 0, width, height);
  }
}

