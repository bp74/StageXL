part of stagexl.drawing;

class GraphicsGradientColorStop {
  final num offset;
  final int color;
  GraphicsGradientColorStop(this.offset, this.color);
}

class GraphicsGradient {

  /// cached by the canvas2D renderer
  CanvasGradient _canvasGradient;

  /// cached by the webgl renderer
  RenderTexture _gradientTexture;

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

  void set kind(String value) {
    if (value != "linear" && value != "radial") throw new ArgumentError("kind must be 'linear' or 'radial'");
    disposeCachedRenderObjects(false);
    _linear = (value == "linear");
  }
  String get kind => _linear ? "linear" : "radial";

  bool get isLinear => _linear;

  void set startX(num value) {
    disposeCachedRenderObjects(false);
    _startX = value;
  }
  num get startX => _startX;

  void set startY(num value) {
    disposeCachedRenderObjects(false);
    _startY = value;
  }
  num get startY => _startY;

  void set startRadius(num value) {
    disposeCachedRenderObjects(false);
    _startRadius = value;
  }
  num get startRadius => _startRadius;

  void set endX(num value) {
    disposeCachedRenderObjects(false);
    _endX = value;
  }
  num get endX => _endX;

  void set endY(num value) {
    disposeCachedRenderObjects(false);
    _endY = value;
  }
  num get endY => _endY;

  void set endRadius(num value) {
    disposeCachedRenderObjects(false);
    _endRadius = value;
  }
  num get endRadius => _endRadius;

  void set colorStops(List<RenderGradientColorStop> value) {
    if ( value != null ) {
      disposeCachedRenderObjects();
      _colorStops = value;
    }
  }
  List<RenderGradientColorStop> get colorStops
  {
    disposeCachedRenderObjects();
    return _colorStops;
  }

  void addColorStop(num offset, int color) {
    disposeCachedRenderObjects();
    _colorStops.add(new GraphicsGradientColorStop(offset, color));
  }

  void disposeCachedRenderObjects([bool colorStopsChanged = true]) {
    _canvasGradient = null;
    if ( colorStopsChanged && _gradientTexture != null ) {
      _gradientTexture.dispose();
      _gradientTexture = null;
    }
  }

  CanvasGradient  getCanvasGradient(CanvasRenderingContext2D context)
  {
    if ( _canvasGradient != null ) return _canvasGradient;

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

    return _canvasGradient;
  }

  static const int GRADIENT_TEXTURE_SIZE = 512;
  RenderTexture  get webGLGradientTexture
  {
    if ( _gradientTexture != null ) return _gradientTexture;

    CanvasElement canvas = new CanvasElement(width: 1, height: GRADIENT_TEXTURE_SIZE);

    var context = canvas.context2D;
    CanvasGradient canvasGradient = context.createLinearGradient(0, 0, 0, GRADIENT_TEXTURE_SIZE);
    for (var colorStop in _colorStops) {
      var offset = colorStop.offset;
      var color = color2rgba(colorStop.color);
      canvasGradient.addColorStop(offset, color);
    }
    context.fillStyle = canvasGradient;
    context.fillRect(0, 0, 1, GRADIENT_TEXTURE_SIZE);

    _gradientTexture = new RenderTexture.fromCanvasElement(canvas);

    return _gradientTexture;
  }

}
