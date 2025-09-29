// ignore_for_file: prefer_interpolation_to_compose_strings, use_string_buffers

part of '../drawing.dart';

class GraphicsGradientColorStop {
  num offset;
  int color;
  GraphicsGradientColorStop(this.offset, this.color);
}

enum GraphicsGradientType { Linear, Radial }

class GraphicsGradient {
  static const int GRADIENT_TEXTURE_SIZE = 512;

  static final SharedCache<String, CanvasGradient> _canvasGradientCache =
      SharedCache<String, CanvasGradient>();

  static final SharedCache<String, RenderTexture> _gradientTextureCache =
      SharedCache<String, RenderTexture>()
        ..onObjectReleased.listen((e) => e.object.dispose());

  /// cached by the Canvas2D renderer
  CanvasGradient? _canvasGradient;
  String? _canvasCacheKey;

  /// cached by the WebGL renderer
  RenderTexture? _gradientTexture;
  String? _textureCacheKey;

  num _startX;
  num _startY;
  num _startRadius;
  num _endX;
  num _endY;
  num _endRadius;

  final List<GraphicsGradientColorStop> _colorStops;
  GraphicsGradientType _type;

  GraphicsGradient.linear(num startX, num startY, num endX, num endY)
      : _startX = startX,
        _startY = startY,
        _startRadius = 0,
        _endX = endX,
        _endY = endY,
        _endRadius = 0,
        _colorStops = <GraphicsGradientColorStop>[],
        _type = GraphicsGradientType.Linear;

  GraphicsGradient.radial(num startX, num startY, num startRadius, num endX,
      num endY, num endRadius)
      : _startX = startX,
        _startY = startY,
        _startRadius = startRadius,
        _endX = endX,
        _endY = endY,
        _endRadius = endRadius,
        _colorStops = <GraphicsGradientColorStop>[],
        _type = GraphicsGradientType.Radial;

  //---------------------------------------------------------------------------

  set type(GraphicsGradientType value) {
    disposeCachedRenderObjects(false);
    _type = value;
  }

  GraphicsGradientType get type => _type;

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
    disposeCachedRenderObjects();
    _colorStops.clear();
    _colorStops.addAll(value);
  }

  List<GraphicsGradientColorStop> get colorStops {
    disposeCachedRenderObjects();
    return _colorStops;
  }

  void addColorStop(num offset, int color) {
    disposeCachedRenderObjects();
    _colorStops.add(GraphicsGradientColorStop(offset, color));
  }

  void disposeCachedRenderObjects([bool colorStopsChanged = true]) {
    if (_canvasCacheKey != null) {
      _canvasGradientCache.releaseObject(_canvasCacheKey!);
    }

    _canvasGradient = null;
    _canvasCacheKey = null;
    if (colorStopsChanged && _gradientTexture != null) {
      if (_textureCacheKey != null) {
        _gradientTextureCache.releaseObject(_textureCacheKey!);
      }
      _gradientTexture = null;
      _textureCacheKey = null;
    }
  }

  CanvasGradient getCanvasGradient(CanvasRenderingContext2D context) {
    if (_canvasGradient == null) {
      _canvasCacheKey = _createCanvasCacheKey();
      _canvasGradient = _canvasGradientCache.getObject(_canvasCacheKey!);
    }

    if (_canvasGradient == null && _type == GraphicsGradientType.Linear) {
      _canvasGradient =
          context.createLinearGradient(_startX, _startY, _endX, _endY);
      _colorStops.forEach((cs) =>
          _canvasGradient!.addColorStop(cs.offset, color2rgba(cs.color)));
      _canvasGradientCache.addObject(_canvasCacheKey!, _canvasGradient!);
    }

    if (_canvasGradient == null && _type == GraphicsGradientType.Radial) {
      _canvasGradient = context.createRadialGradient(
          _startX, _startY, _startRadius, _endX, _endY, _endRadius);
      _colorStops.forEach((cs) =>
          _canvasGradient!.addColorStop(cs.offset, color2rgba(cs.color)));
      _canvasGradientCache.addObject(_canvasCacheKey!, _canvasGradient!);
    }

    return _canvasGradient!;
  }

  RenderTexture getRenderTexture() {
    if (_gradientTexture == null) {
      _textureCacheKey = _createTextureCacheKey();
      _gradientTexture = _gradientTextureCache.getObject(_textureCacheKey!);
    }

    if (_gradientTexture == null) {
      final canvas = HTMLCanvasElement()
        ..width = 1
        ..height = GRADIENT_TEXTURE_SIZE;
      final canvasGradient =
          canvas.context2D.createLinearGradient(0, 0, 0, GRADIENT_TEXTURE_SIZE);
      _colorStops.forEach(
          (cs) => canvasGradient.addColorStop(cs.offset, color2rgba(cs.color)));
      canvas.context2D.fillStyle = canvasGradient;
      canvas.context2D.fillRect(0, 0, 1, GRADIENT_TEXTURE_SIZE);
      _gradientTexture = RenderTexture.fromCanvasElement(canvas);
      _gradientTextureCache.addObject(_textureCacheKey!, _gradientTexture!);
    }

    return _gradientTexture!;
  }

  String _createCanvasCacheKey() {
    // TODO: Profile to see if using a StringBuffer is faster here.
    var key = '';

    if (_type == GraphicsGradientType.Linear) {
      key += 'L';
      key += '_' + _startX.toStringAsFixed(3);
      key += '_' + _startY.toStringAsFixed(3);
      key += '_' + _endX.toStringAsFixed(3);
      key += '_' + _endY.toStringAsFixed(3);
    } else if (_type == GraphicsGradientType.Radial) {
      key += 'R';
      key += '_' + _startX.toStringAsFixed(3);
      key += '_' + _startY.toStringAsFixed(3);
      key += '_' + _startRadius.toStringAsFixed(3);
      key += '_' + _endX.toStringAsFixed(3);
      key += '_' + _endY.toStringAsFixed(3);
      key += '_' + _endRadius.toStringAsFixed(3);
    } else {
      throw StateError('Unknown gradient kind');
    }

    key += '_' + _colorStops.length.toString();

    for (var colorStop in _colorStops) {
      key += '_' + colorStop.offset.toStringAsPrecision(3);
      key += '_' + colorStop.color.toRadixString(16);
    }

    return key;
  }

  String _createTextureCacheKey() {
    var key = _colorStops.length.toString();
    for (var colorStop in _colorStops) {
      key += '_' + colorStop.offset.toStringAsPrecision(3);
      key += '_' + colorStop.color.toRadixString(16);
    }
    return key;
  }
}
