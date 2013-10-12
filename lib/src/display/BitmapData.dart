part of stagexl;

class BitmapData implements BitmapDrawable {

  int _width;
  int _height;
  bool _transparent;
  num _pixelRatio;
  num _pixelRatioSource;

  int _renderMode;
  int _destinationWidth;
  int _destinationHeight;
  int _destinationX;
  int _destinationY;
  int _sourceX;
  int _sourceY;
  int _sourceWidth;
  int _sourceHeight;

  CanvasImageSource _source;
  CanvasRenderingContext2D _context;

  static BitmapDataLoadOptions defaultLoadOptions = new BitmapDataLoadOptions();

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapData(int width, int height, [bool transparent = true, int fillColor = 0xFFFFFFFF, pixelRatio = 1.0]) {

    _width = _ensureInt(width);
    _height = _ensureInt(height);
    _transparent = transparent;
    _pixelRatio = pixelRatio.toDouble();
    _pixelRatioSource = _pixelRatio / _backingStorePixelRatio;

    _renderMode = ((1.0 - _pixelRatioSource).abs() < 0.001) ? 0 : 1;
    _destinationX = 0;
    _destinationY = 0;
    _destinationWidth = _width;
    _destinationHeight = _height;
    _sourceX = 0;
    _sourceY = 0;
    _sourceWidth = (_width * _pixelRatioSource).ceil();
    _sourceHeight = (_height * _pixelRatioSource).ceil();

    var canvas = new CanvasElement(width: _sourceWidth, height: _sourceHeight);

    _source = canvas;
    _context = canvas.context2D;
    _context.fillStyle = _transparent ? _color2rgba(fillColor) : _color2rgb(fillColor);
    _context.fillRect(0, 0, _sourceWidth, _sourceHeight);
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromImageElement(ImageElement imageElement, [num pixelRatio = 1.0]) {

    var imageWidth = _ensureInt(imageElement.naturalWidth);
    var imageHeight = _ensureInt(imageElement.naturalHeight);

    _transparent = true;
    _pixelRatio = _ensureNum(pixelRatio);
    _pixelRatioSource = _pixelRatio;
    _width = (imageWidth / _pixelRatio).round();
    _height = (imageHeight / _pixelRatio).round();

    _renderMode = ((1.0 - _pixelRatioSource).abs() < 0.001) ? 0 : 1;
    _destinationX = 0;
    _destinationY = 0;
    _destinationWidth = _width;
    _destinationHeight = _height;
    _sourceX = 0;
    _sourceY = 0;
    _sourceWidth = imageWidth;
    _sourceHeight = imageHeight;

    _source = imageElement;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromTextureAtlasFrame(TextureAtlasFrame textureAtlasFrame) {

    var bitmapData = textureAtlasFrame.textureAtlas._bitmapData;

    _width = textureAtlasFrame.originalWidth.toInt();
    _height = textureAtlasFrame.originalHeight.toInt();
    _transparent = true;
    _pixelRatio = bitmapData._pixelRatio;
    _pixelRatioSource = bitmapData._pixelRatioSource;

    _renderMode = textureAtlasFrame.rotated ? 3 : 2;
    _destinationX = textureAtlasFrame.offsetX;
    _destinationY = textureAtlasFrame.offsetY;
    _destinationWidth = textureAtlasFrame.frameWidth;
    _destinationHeight = textureAtlasFrame.frameHeight;
    _sourceX = (textureAtlasFrame.frameX * _pixelRatioSource).floor();
    _sourceY = (textureAtlasFrame.frameY * _pixelRatioSource).floor();
    _sourceWidth = (textureAtlasFrame.frameWidth * _pixelRatioSource).ceil();
    _sourceHeight = (textureAtlasFrame.frameHeight * _pixelRatioSource).ceil();

    _source = bitmapData._source;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<BitmapData> load(String url,
      [BitmapDataLoadOptions bitmapDataLoadOptions = null, num pixelRatio = 1.0]) {

    if (bitmapDataLoadOptions == null) {
      bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    }

    if (Stage.autoHiDpi && bitmapDataLoadOptions.autoHiDpi) {
      if (url.contains("@1x.") && _devicePixelRatio >= 1.5) {
        pixelRatio = pixelRatio * 2.0;
        url = url.replaceAll("@1x.", "@2x.");
      }
    }

    Completer<BitmapData> completer = new Completer<BitmapData>();

    ImageElement imageElement = new ImageElement();
    StreamSubscription onLoadSubscription;
    StreamSubscription onErrorSubscription;

    onLoadSubscription = imageElement.onLoad.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.complete(new BitmapData.fromImageElement(imageElement, pixelRatio));
    });

    onErrorSubscription = imageElement.onError.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.completeError(new StateError("Failed to load image."));
    });

    if (bitmapDataLoadOptions.webp == false) {
      imageElement.src = url;
      return completer.future;
    }

    //---------------------------

    _isWebpSupported.then((bool webpSupported) {

      var regex = new RegExp(r"(png|jpg|jpeg)$", multiLine:false, caseSensitive:true);
      var match = regex.firstMatch(url);

      if (webpSupported == false || match == null) {
        imageElement.src = url;
      } else {
        imageElement.src = url.substring(0, url.length - match.group(1).length) + "webp";
      }
    });

    return completer.future;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  int get width => _width;
  int get height => _height;
  Rectangle get rectangle => new Rectangle(0, 0, _width, _height);

  num get pixelRatio => _pixelRatio;

  //-------------------------------------------------------------------------------------------------

  ImageData getImageData(int x, int y, int width, int height, [num pixelRatio]) {

    if (pixelRatio != null && pixelRatio != _pixelRatio) {
      var tempBitmapData = new BitmapData(width, height, true, 0, pixelRatio);
      tempBitmapData.draw(this, new Matrix(1.0, 0.0, 0.0, 1.0, -x, -y));
      return tempBitmapData.getImageData(x, y, width, height);
    }

    _ensureContext();

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    if (_backingStorePixelRatio > 1.0) {
      return _context.getImageDataHD(x * pr, y * pr, width * pr, height * pr);
    } else {
      return _context.getImageData(x * prs, y * prs, width * prs, height * prs);
    }
  }

  void putImageData(ImageData imageData, int x, int y) {

    _ensureContext();

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    if (_backingStorePixelRatio > 1.0) {
      _context.putImageDataHD(imageData, x * pr, y * pr);
    } else {
      _context.putImageData(imageData, x * prs, y * prs);
    }
  }

  ImageData createImageData(int width, int height) {

    _ensureContext();

    var pr = _pixelRatio;
    var prs = _pixelRatioSource;

    return _context.createImageData(width * pr, height * pr);
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData clone([num pixelRatio]) {

    pixelRatio = (pixelRatio != null) ? pixelRatio : _pixelRatio;

    var bitmapData = new BitmapData(_width, _height, true, 0, pixelRatio);
    bitmapData.draw(this);

    return bitmapData;
  }

  //-------------------------------------------------------------------------------------------------

  void applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint, BitmapFilter filter) {

    filter.apply(sourceBitmapData, sourceRect, this, destPoint);
  }

  //-------------------------------------------------------------------------------------------------

  void colorTransform(Rectangle rect, ColorTransform transform) {

    int redMultiplier = (1024 * transform.redMultiplier).toInt();
    int greenMultiplier = (1024 * transform.greenMultiplier).toInt();
    int blueMultiplier = (1024 * transform.blueMultiplier).toInt();
    int alphaMultiplier = (1024 * transform.alphaMultiplier).toInt();

    int redOffset = transform.redOffset;
    int greenOffset = transform.greenOffset;
    int blueOffset = transform.blueOffset;
    int alphaOffset = transform.alphaOffset;

    var isLittleEndianSystem = _isLittleEndianSystem;

    int mulitplier0 = isLittleEndianSystem ? redMultiplier : alphaMultiplier;
    int mulitplier1 = isLittleEndianSystem ? greenMultiplier : blueMultiplier;
    int mulitplier2 = isLittleEndianSystem ? blueMultiplier : greenMultiplier;
    int mulitplier3 = isLittleEndianSystem ? alphaMultiplier : redMultiplier;

    int offset0 = isLittleEndianSystem ? redOffset : alphaOffset;
    int offset1 = isLittleEndianSystem ? greenOffset : blueOffset;
    int offset2 = isLittleEndianSystem ? blueOffset : greenOffset;
    int offset3 = isLittleEndianSystem ? alphaOffset : redOffset;

    var imageData = getImageData(rect.x, rect.y, rect.width, rect.height);
    var data = imageData.data;

    for (int i = 0; i <= data.length - 4; i += 4) {
      int c0 = data[i + 0];
      int c1 = data[i + 1];
      int c2 = data[i + 2];
      int c3 = data[i + 3];

      if (c0 is! num) continue; // dart2js hint
      if (c1 is! num) continue; // dart2js hint
      if (c2 is! num) continue; // dart2js hint
      if (c3 is! num) continue; // dart2js hint

      data[i + 0] = offset0 + ((c0 * mulitplier0) >> 10);
      data[i + 1] = offset1 + ((c1 * mulitplier1) >> 10);
      data[i + 2] = offset2 + ((c2 * mulitplier2) >> 10);
      data[i + 3] = offset3 + ((c3 * mulitplier3) >> 10);
    }

    putImageData(imageData, rect.x, rect.y);
  }

  //-------------------------------------------------------------------------------------------------

  void copyPixels(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint) {

    _ensureContext();
    sourceBitmapData._ensureContext();

    var sourceContext = sourceBitmapData._context;
    var sourceCanvas = sourceContext.canvas;
    var sourcePixelRatio = sourceBitmapData._pixelRatioSource;
    var sx = sourcePixelRatio * sourceRect.x;
    var sy = sourcePixelRatio * sourceRect.y;
    var sw = sourcePixelRatio * sourceRect.width;
    var sh = sourcePixelRatio * sourceRect.height;

    var destinationContext = _context;
    var destinationPixelRatio = _pixelRatioSource;
    var dx = destinationPixelRatio * destPoint.x;
    var dy = destinationPixelRatio * destPoint.y;
    var dw = destinationPixelRatio * sourceRect.width;
    var dh = destinationPixelRatio * sourceRect.height;

    destinationContext.clearRect(dx, dy, dw, dh);
    destinationContext.drawImageScaledFromSource(sourceCanvas, sx, sy, sw, sh, dx, dy, dw, dh);
  }

  //-------------------------------------------------------------------------------------------------

  void drawPixels(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint,
                  [String compositeOperation = null]) {

    _ensureContext();
    sourceBitmapData._ensureContext();

    var sourceContext = sourceBitmapData._context;
    var sourceCanvas = sourceContext.canvas;
    var sourcePixelRatio = sourceBitmapData._pixelRatioSource;
    var sx = sourcePixelRatio * sourceRect.x;
    var sy = sourcePixelRatio * sourceRect.y;
    var sw = sourcePixelRatio * sourceRect.width;
    var sh = sourcePixelRatio * sourceRect.height;

    var destinationContext = _context;
    var destinationPixelRatio = _pixelRatioSource;
    var dx = destinationPixelRatio * destPoint.x;
    var dy = destinationPixelRatio * destPoint.y;
    var dw = destinationPixelRatio * sourceRect.width;
    var dh = destinationPixelRatio * sourceRect.height;

    if (compositeOperation != null) {
      destinationContext.globalCompositeOperation = compositeOperation;
      destinationContext.drawImageScaledFromSource(sourceCanvas, sx, sy, sw, sh, dx, dy, dw, dh);
      destinationContext.globalCompositeOperation = CompositeOperation.SOURCE_OVER;
    } else {
      destinationContext.drawImageScaledFromSource(sourceCanvas, sx, sy, sw, sh, dx, dy, dw, dh);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void draw(BitmapDrawable source, [Matrix matrix = null]) {

    _ensureContext();

    matrix = (matrix == null) ? new Matrix.fromIdentity() : matrix.clone();
    matrix.scale(_pixelRatioSource, _pixelRatioSource);

    var renderState = new RenderState.fromCanvasRenderingContext2D(_context, matrix);
    source.render(renderState);

    _context.globalAlpha = 1.0;
    _context.globalCompositeOperation = CompositeOperation.SOURCE_OVER;
  }

  //-------------------------------------------------------------------------------------------------

  void fillRect(Rectangle rect, int color) {

    _ensureContext();

    _context.setTransform(_pixelRatioSource, 0.0, 0.0, _pixelRatioSource, 0.0, 0.0);
    _context.fillStyle = _color2rgba(color);
    _context.fillRect(rect.x, rect.y, rect.width, rect.height);
  }

  //-------------------------------------------------------------------------------------------------

  void clear() {

    _ensureContext();

    _context.setTransform(_pixelRatioSource, 0.0, 0.0, _pixelRatioSource, 0.0, 0.0);
    _context.clearRect(0, 0, _width, _height);
  }

  //-------------------------------------------------------------------------------------------------

  int getPixel(int x, int y) {
    return getPixel32(x, y) & 0x00FFFFFF;
  }

  void setPixel(int x, int y, int color) {
    setPixel32(x, y, color | 0xFF000000);
  }

  //-------------------------------------------------------------------------------------------------

  int getPixel32(int x, int y) {

    var imageData = getImageData(x, y, 1, 1);
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;
    var r = 0, g = 0, b = 0, a = 0;

    for(int p = 0; p < pixels; p++) {
      r += _isLittleEndianSystem ? data[p * 4 + 0] : data[p * 4 + 3];
      g += _isLittleEndianSystem ? data[p * 4 + 1] : data[p * 4 + 2];
      b += _isLittleEndianSystem ? data[p * 4 + 2] : data[p * 4 + 1];
      a += _isLittleEndianSystem ? data[p * 4 + 3] : data[p * 4 + 0];
    }

    return ((a ~/ pixels) << 24) + ((r ~/ pixels) << 16) + ((g ~/ pixels) << 8) + ((b ~/ pixels) << 0);
  }

  void setPixel32(int x, int y, int color) {

    var imageData = createImageData(1, 1);
    var pixels = imageData.width * imageData.height;
    var data = imageData.data;

    for(int p = 0; p < pixels; p++) {
      data[p * 4 + 0] = _isLittleEndianSystem ? (color >> 16) & 0xFF : (color >> 24) & 0xFF;
      data[p * 4 + 1] = _isLittleEndianSystem ? (color >>  8) & 0xFF : (color >>  0) & 0xFF;
      data[p * 4 + 2] = _isLittleEndianSystem ? (color >>  0) & 0xFF : (color >>  8) & 0xFF;
      data[p * 4 + 3] = _isLittleEndianSystem ? (color >> 24) & 0xFF : (color >> 16) & 0xFF;
    }

    putImageData(imageData, x, y);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var renderStateContext = renderState.context;

    switch(_renderMode) {

      case 0:
        renderStateContext.drawImage(_source,
            _destinationX, _destinationY);
        break;

      case 1:
        renderStateContext.drawImageScaled(_source,
            _destinationX, _destinationY, _destinationWidth, _destinationHeight);
        break;

      case 2:
        renderStateContext.drawImageScaledFromSource(_source,
            _sourceX, _sourceY, _sourceWidth, _sourceHeight,
            _destinationX, _destinationY, _destinationWidth, _destinationHeight);
        break;

      case 3:
        renderStateContext.transform(0.0, -1.0, 1.0, 0.0, _destinationX, _destinationY + _destinationHeight);
        renderStateContext.drawImageScaledFromSource(_source,
            _sourceX, _sourceY, _sourceHeight, _sourceWidth,
            0.0 , 0.0, _destinationHeight, _destinationWidth);
        break;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void renderClipped(RenderState renderState, Rectangle clipRectangle) {

    if (clipRectangle.width == 0 ||  clipRectangle.height == 0) return;

    var renderStateContext = renderState.context;

    // Drawing a clipped BitmapData with a _renderMode other than 0 is pretty complicated.
    // Therefore we convert all BitmapDatas to _renderMode 0 and use a simple drawing method.

    if (_renderMode != 0) {
      _ensureContext();
    }

    var sourceX = (clipRectangle.x - _destinationX) * _pixelRatioSource;
    var sourceY = (clipRectangle.y - _destinationY) * _pixelRatioSource;
    var sourceWidth = clipRectangle.width * _pixelRatioSource;
    var sourceHeight = clipRectangle.height * _pixelRatioSource;
    var destinationX = clipRectangle.x + _destinationX;
    var destinationY = clipRectangle.y + _destinationY;
    var destinationWidth = clipRectangle.width;
    var destinationHeight = clipRectangle.height;

    renderStateContext.drawImageScaledFromSource(_source,
        sourceX, sourceY, sourceWidth, sourceHeight,
        destinationX, destinationY, destinationWidth, destinationHeight);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void _ensureContext() {

    if (_context == null) {

      var pixelRatioSource = _pixelRatio / _backingStorePixelRatio;
      var sourceWidth = (_width * pixelRatioSource).ceil();
      var sourceHeight = (_height * pixelRatioSource).ceil();

      var canvas = new CanvasElement(width: sourceWidth, height: sourceHeight);
      var matrix = new Matrix(pixelRatioSource, 0.0, 0.0, pixelRatioSource, 0.0, 0.0);
      var renderState = new RenderState.fromCanvasRenderingContext2D(canvas.context2D, matrix);
      this.render(renderState);

      _pixelRatio = _pixelRatio;
      _pixelRatioSource = pixelRatioSource;

      _renderMode = ((1.0 - _pixelRatioSource).abs() < 0.001) ? 0 : 1;
      _destinationX = 0;
      _destinationY = 0;
      _destinationWidth = _width;
      _destinationHeight = _height;
      _sourceX = 0;
      _sourceY = 0;
      _sourceWidth = sourceWidth;
      _sourceHeight = sourceHeight;

      _source = canvas;
      _context = canvas.context2D;
    }
  }
}
