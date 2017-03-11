part of stagexl.drawing;

class GraphicsGradientColorStop {
  num offset;
  int color;
  GraphicsGradientColorStop(this.offset, this.color);
}


class GraphicsGradient {

  /// cached by the canvas2D renderer
  CanvasGradient  _canvasGradient;
  String          _canvasCacheKey;
  static SharedCache<String,CanvasGradient>  _canvasGradientCache = new SharedCache<String,CanvasGradient>();

  /// cached by the webgl renderer
  RenderTexture   _gradientTexture;
  String          _textureCacheKey;
  static SharedCache<String,RenderTexture>  _gradientTextureCache = new SharedCache<String,RenderTexture>()..onObjectReleasedListen(releaseTexture);

  num _startX;
  num _startY;
  num _startRadius;
  num _endX;
  num _endY;
  num _endRadius;

  List<GraphicsGradientColorStop> _colorStops;
  bool _linear;

  GraphicsGradient.linear(this._startX, this._startY, this._endX, this._endY) :
      this._colorStops = new List<GraphicsGradientColorStop>(),
      this._linear = true;

  GraphicsGradient.radial(this._startX, this._startY, this._startRadius, this._endX, this._endY, this._endRadius) :
      this._colorStops = new List<GraphicsGradientColorStop>(),
      this._linear = false;

  //---------------------------------------------------------------------------

  set kind(String value) {
    if (value != "linear" && value != "radial") throw new ArgumentError("kind must be 'linear' or 'radial'");
    disposeCachedRenderObjects(false);
    _linear = (value == "linear");
  }
  String get kind => _linear ? "linear" : "radial";

  bool get isLinear => _linear;

  set startX(num value) {
    disposeCachedRenderObjects(false);
    _startX = value;
  }
  num get startX => _startX;

  set startY(num value) {
    disposeCachedRenderObjects(false);
    _startY = value;
  }
  num get startY => _startY;

  set startRadius(num value) {
    disposeCachedRenderObjects(false);
    _startRadius = value;
  }
  num get startRadius => _startRadius;

  set endX(num value) {
    disposeCachedRenderObjects(false);
    _endX = value;
  }
  num get endX => _endX;

  set endY(num value) {
    disposeCachedRenderObjects(false);
    _endY = value;
  }
  num get endY => _endY;

  set endRadius(num value) {
    disposeCachedRenderObjects(false);
    _endRadius = value;
  }
  num get endRadius => _endRadius;

  set colorStops(List<GraphicsGradientColorStop> value) {
    if ( value != null ) {
      disposeCachedRenderObjects();
      _colorStops.clear();
      _colorStops.addAll(value);
    }
  }
  List<GraphicsGradientColorStop> get colorStops {
    disposeCachedRenderObjects();
    return _colorStops;
  }

  void addColorStop(num offset, int color) {
    disposeCachedRenderObjects();
    _colorStops.add(new GraphicsGradientColorStop(offset, color));
  }

  void disposeCachedRenderObjects([bool colorStopsChanged = true]) {
    _canvasGradientCache.releaseObject(_canvasCacheKey);
    _canvasGradient = null;
    _canvasCacheKey = null;
    if ( colorStopsChanged && _gradientTexture != null ) {
      _gradientTextureCache.releaseObject(_textureCacheKey);
      _gradientTexture = null;
      _textureCacheKey = null;
    }
  }

  CanvasGradient  getCanvasGradient(CanvasRenderingContext2D context)
  {
    if ( _canvasGradient != null ) return _canvasGradient;

    _canvasCacheKey = _createCanvasCacheKey();
    _canvasGradient = _canvasGradientCache.getObject(_canvasCacheKey);

    if ( _canvasGradient == null ) {

      if ( _linear ) {
        _canvasGradient = context.createLinearGradient(_startX, _startY, _endX, _endY);
      } else {
        _canvasGradient = context.createRadialGradient(_startX, _startY, _startRadius, _endX, _endY, _endRadius);
      }

      for (var colorStop in _colorStops) {
        var offset = colorStop.offset;
        var color = color2rgba(colorStop.color);
        _canvasGradient.addColorStop(offset, color);
      }

      _canvasGradientCache.addObject(_canvasCacheKey,_canvasGradient);
    }

    return _canvasGradient;
  }

  static const int GRADIENT_TEXTURE_SIZE = 512;
  RenderTexture  get webGLGradientTexture
  {
    if ( _gradientTexture != null ) return _gradientTexture;

    _textureCacheKey = _createTextureCacheKey();
    _gradientTexture = _gradientTextureCache.getObject(_textureCacheKey);

    if ( _gradientTexture == null ) {
      CanvasElement canvas = new CanvasElement( width: 1, height: GRADIENT_TEXTURE_SIZE);

      var context = canvas.context2D;
      CanvasGradient canvasGradient = context.createLinearGradient(
          0, 0, 0, GRADIENT_TEXTURE_SIZE);
      for (var colorStop in _colorStops) {
        var offset = colorStop.offset;
        var color = color2rgba(colorStop.color);
        canvasGradient.addColorStop(offset, color);
      }
      context.fillStyle = canvasGradient;
      context.fillRect(0, 0, 1, GRADIENT_TEXTURE_SIZE);

      _gradientTexture = new RenderTexture.fromCanvasElement(canvas);

      _gradientTextureCache.addObject(_textureCacheKey,_gradientTexture);
    }

    return _gradientTexture;
  }

  String  _createCanvasCacheKey()
  {
    String key = _linear ? "L_" : "R_";
    key += _startX.toStringAsFixed(3) + "_" + _startY.toStringAsFixed(3);
    key += "_" + _endX.toStringAsFixed(3) + "_" + _endX.toStringAsFixed(3);
    if ( !_linear )
    {
      key += "_" + _startRadius.toStringAsFixed(3) + "_" + _endRadius.toStringAsFixed(3);
    }

    key += "_" + _colorStops.length.toString();
    for (var colorStop in _colorStops) {
      key += "_" + colorStop.offset.toStringAsPrecision(3) + "_" + colorStop.color.toRadixString(16);
    }

    return key;
  }

  String  _createTextureCacheKey()
  {
    String key = _colorStops.length.toString();
    for (var colorStop in _colorStops) {
      key += "_" + colorStop.offset.toStringAsPrecision(3) + "_" + colorStop.color.toRadixString(16);
    }
    return key;
  }

  static void releaseTexture(ObjectReleaseEvent event)
  {
    RenderTexture texture = event.object as RenderTexture;
    if ( texture != null ) {
      texture.dispose();
    }
  }
}
