part of stagexl;

class BitmapData implements BitmapDrawable {
  
  int _width;
  int _height;
  bool _transparent;

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

  static BitmapDataLoadOptions defaultLoadOptions = new BitmapDataLoadOptions(png:true, jpg:true, webp:false);
  
  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapData(int width, int height, [bool transparent = true, int fillColor = 0xFFFFFFFF]) {
    
    _width = width.toInt();
    _height = height.toInt();
    _transparent = transparent;
    
    _renderMode = 0;
    _destinationX = _sourceX = 0;
    _destinationY = _sourceY = 0;
    _destinationWidth = _sourceWidth = _width;
    _destinationHeight = _sourceHeight = _height;
    
    var canvas = new CanvasElement(width: _width, height: _height);

    _context = canvas.context2D;
    _context.fillStyle = _transparent ? _color2rgba(fillColor) : _color2rgb(fillColor);
    _context.fillRect(0, 0, _width, _height);

    _source = canvas;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromImageElement(ImageElement imageElement) {
    
    if (imageElement == null)
      throw new ArgumentError();
    
    _width = imageElement.naturalWidth.toInt();
    _height = imageElement.naturalHeight.toInt();
    _transparent = true;

    _renderMode = 0;
    _destinationX = _sourceX = 0;
    _destinationY = _sourceY = 0;
    _destinationWidth = _sourceWidth = _width;
    _destinationHeight = _sourceHeight = _height;

    _source = imageElement;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromTextureAtlasFrame(TextureAtlasFrame textureAtlasFrame) {

    _width = textureAtlasFrame.originalWidth.toInt();
    _height = textureAtlasFrame.originalHeight.toInt();
    _transparent = true;

    _renderMode = textureAtlasFrame.rotated ? 2 : 1;
    _destinationX = textureAtlasFrame.offsetX;
    _destinationY = textureAtlasFrame.offsetY;
    _destinationWidth = textureAtlasFrame.frameWidth;
    _destinationHeight = textureAtlasFrame.frameHeight;
    _sourceX = textureAtlasFrame.frameX;
    _sourceY = textureAtlasFrame.frameY;
    _sourceWidth = textureAtlasFrame.frameWidth;
    _sourceHeight = textureAtlasFrame.frameHeight;
   
    _source = textureAtlasFrame.textureAtlas._bitmapData._source;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<BitmapData> load(String url, [BitmapDataLoadOptions bitmapDataLoadOptions = null]) {
    
    if (bitmapDataLoadOptions == null) bitmapDataLoadOptions = BitmapData.defaultLoadOptions;
    
    Completer<BitmapData> completer = new Completer<BitmapData>();

    ImageElement imageElement = new ImageElement();
    StreamSubscription onLoadSubscription;
    StreamSubscription onErrorSubscription;
    
    onLoadSubscription = imageElement.onLoad.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.complete(new BitmapData.fromImageElement(imageElement));
    });
    
    onErrorSubscription = imageElement.onError.listen((event) {
      onLoadSubscription.cancel();
      onErrorSubscription.cancel();
      completer.completeError(new StateError("Error loading image."));
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
 
  //-------------------------------------------------------------------------------------------------

  BitmapData clone() {
    
    BitmapData bitmapData = new BitmapData(_width, _height, true, 0);
    bitmapData.draw(this);

    return bitmapData;
  }

  //-------------------------------------------------------------------------------------------------

  void applyFilter(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint, BitmapFilter filter) {
    
    filter.apply(sourceBitmapData, sourceRect, this, destPoint);
  }

  //-------------------------------------------------------------------------------------------------

  void colorTransform(Rectangle rect, ColorTransform transform) {
    
    var context = _getContext();
    var image = context.getImageData(rect.x, rect.y, rect.width, rect.height);
    var data = image.data;
    var length = data.length;

    int r = transform.redOffset;
    int g = transform.greenOffset;
    int b = transform.blueOffset;
    int a = transform.alphaOffset;

    num rm = transform.redMultiplier;
    num gm = transform.greenMultiplier;
    num bm = transform.blueMultiplier;
    num am = transform.alphaMultiplier;

    if (_isLittleEndianSystem) {
      for (int i = 0; i <= length - 4; i += 4) {
        data[i + 0] = data[i + 0] * (1 - rm) + (r * rm);
        data[i + 1] = data[i + 1] * (1 - gm) + (g * gm);
        data[i + 2] = data[i + 2] * (1 - bm) + (b * bm);
        data[i + 3] = data[i + 3] * (1 - am) + (a * am);
      }
    } else {
      for (int i = 0; i <= length - 4; i += 4) {
        data[i + 0] = data[i + 0] * (1 - am) + (a * am);
        data[i + 1] = data[i + 1] * (1 - bm) + (b * bm);
        data[i + 2] = data[i + 2] * (1 - gm) + (g * gm);
        data[i + 3] = data[i + 3] * (1 - rm) + (r * rm);
      }
    }

    context.putImageData(image, rect.x, rect.y);
  }

  //-------------------------------------------------------------------------------------------------

  void copyPixels(BitmapData sourceBitmapData, Rectangle sourceRect, Point destPoint, [BitmapData alphaBitmapData = null, Point alphaPoint = null, bool mergeAlpha = false]) {
    
    var imageData = sourceBitmapData._getContext().getImageData(sourceRect.x, sourceRect.y, sourceRect.width, sourceRect.height);
    _getContext().putImageData(imageData, destPoint.x, destPoint.y);
  }

  //-------------------------------------------------------------------------------------------------

  void draw(BitmapDrawable source, [Matrix matrix = null]) {
    
    var context = _getContext();
    var renderState = new RenderState.fromCanvasRenderingContext2D(context, matrix);
    
    source.render(renderState);
    context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
  }

  //-------------------------------------------------------------------------------------------------

  void fillRect(Rectangle rect, int color) {
    
    var context = _getContext();

    context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    context.fillStyle = _color2rgba(color);
    context.fillRect(rect.x, rect.y, rect.width, rect.height);
  }
  
  //-------------------------------------------------------------------------------------------------

  void clear() {
    
    var context = _getContext();
    
    context.clearRect(0, 0, _width, _height);
  }

  //-------------------------------------------------------------------------------------------------

  int getPixel(int x, int y) {
    
    var context = _getContext();
    var imageData = context.getImageData(x, y, 1, 1);
    var data = imageData.data;

    if (_isLittleEndianSystem) {
      return (data[0] << 16) + (data[1] << 8) + (data[2] << 0);
    } else {
      return (data[3] << 16) + (data[2] << 8) + (data[1] << 0);
    }
  }

  //-------------------------------------------------------------------------------------------------

  int getPixel32(int x, int y) {
    
    var context = _getContext();
    var imageData = context.getImageData(x, y, 1, 1);
    var data = imageData.data;

    if (_isLittleEndianSystem) {
      return (data[0] << 16) + (data[1] << 8) + (data[2] << 0) + (data[3] << 24);
    } else {
      return (data[3] << 16) + (data[2] << 8) + (data[1] << 0) + (data[0] << 24);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void setPixel(int x, int y, int color) {
    
    var context = _getContext();
    var imageData = context.getImageData(x, y, 1, 1);
    var data = imageData.data;

    if (_isLittleEndianSystem) {
      data[0] = (color >> 16) & 0xFF;
      data[1] = (color >>  8) & 0xFF;
      data[2] = (color >>  0) & 0xFF;
    } else {
      data[1] = (color >>  0) & 0xFF;
      data[2] = (color >>  8) & 0xFF;
      data[3] = (color >> 16) & 0xFF;
    }

    context.putImageData(imageData, x, y);
  }

  //-------------------------------------------------------------------------------------------------

  void setPixel32(int x, int y, int color) {
    
    var context = _getContext();
    var imageData = context.getImageData(x, y, 1, 1);
    var data = imageData.data;

    if (_isLittleEndianSystem) {
      data[0] = (color >> 16) & 0xFF;
      data[1] = (color >>  8) & 0xFF;
      data[2] = (color >>  0) & 0xFF;
      data[3] = (color >> 24) & 0xFF;
    } else {
      data[0] = (color >> 24) & 0xFF;
      data[1] = (color >>  0) & 0xFF;
      data[2] = (color >>  8) & 0xFF;
      data[3] = (color >> 16) & 0xFF;
    }

    context.putImageData(imageData, x, y);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {
    
    var renderStateContext = renderState.context;

    switch(_renderMode) {
      
      case 0:
        renderStateContext.drawImage(_source, _destinationX, _destinationY);
        break;

      case 1:
        renderStateContext.drawImageScaledFromSource(_source,
            _sourceX, _sourceY, _sourceWidth, _sourceHeight,
            _destinationX, _destinationY, _destinationWidth, _destinationHeight);
        break;

      case 2:
        renderStateContext.transform(0.0, -1.0, 1.0, 0.0, _destinationX, _destinationY + _destinationHeight);
        renderStateContext.drawImageScaledFromSource(_source, 
            _sourceX, _sourceY, _sourceHeight, _sourceWidth, 
            0.0 , 0.0, _destinationHeight, _destinationWidth);
        break;
        
      case 3:
        renderStateContext.drawImageScaled(_source, _destinationX, _destinationY, _destinationWidth, _destinationHeight);
        break;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void renderClipped(RenderState renderState, Rectangle clipRectangle) {
    
    var renderStateContext = renderState.context;
    
    if (clipRectangle.width <= 0.0 || clipRectangle.height <= 0.0)
      return;
    
    switch(_renderMode) {
      
      case 0:

        renderStateContext.drawImageScaledFromSource(_source, 
            clipRectangle.x - _destinationX, clipRectangle.y - _destinationY, clipRectangle.width, clipRectangle.height,
            clipRectangle.x + _destinationX, clipRectangle.y + _destinationY, clipRectangle.width, clipRectangle.height);
        
        break;

      case 1:

        var fLeft = _sourceX;
        var fTop =  _sourceY;
        var fRight = fLeft + _sourceWidth;
        var fBottom = fTop + _sourceHeight;

        var cLeft = _sourceX - _destinationX + clipRectangle.x;
        var cTop =  _sourceY - _destinationY + clipRectangle.y;
        var cRight = cLeft + clipRectangle.width;
        var cBottom = cTop + clipRectangle.height;

        var iLeft = (fLeft > cLeft) ? fLeft : cLeft;
        var iTop =  (fTop > cTop) ? fTop : cTop;
        var iRight = (fRight < cRight) ? fRight : cRight;
        var iBottom = (fBottom < cBottom) ? fBottom : cBottom;
        var iWidth = iRight - iLeft;
        var iHeight = iBottom - iTop;
        var destinationX = _destinationX - fLeft + iLeft;
        var destinationY = _destinationY - fTop + iTop;

        if (iWidth > 0.0 && iHeight > 0.0) {
          renderStateContext.drawImageScaledFromSource(_source, 
              iLeft, iTop, iWidth, iHeight, 
              destinationX, destinationY, iWidth, iHeight);
        }

        break;

      case 2:

        var fLeft = _sourceX;
        var fTop =  _sourceY;
        var fRight = fLeft + _sourceHeight;
        var fBottom = fTop + _sourceWidth;

        var cLeft = _sourceX + _destinationY - clipRectangle.y + _destinationHeight - clipRectangle.height;
        var cTop =  _sourceY - _destinationX + clipRectangle.x;
        var cRight = cLeft + clipRectangle.height;
        var cBottom = cTop + clipRectangle.width;

        var iLeft = (fLeft > cLeft) ? fLeft : cLeft;
        var iTop =  (fTop > cTop) ? fTop : cTop;
        var iRight = (fRight < cRight) ? fRight : cRight;
        var iBottom = (fBottom < cBottom) ? fBottom : cBottom;
        var iWidth = iBottom - iTop;
        var iHeight = iRight - iLeft;
        var destinationX = _destinationX - fTop + iTop;
        var destinationY = _destinationY + fRight - iRight;
        
        if (iWidth > 0.0 && iHeight > 0.0) {
          renderStateContext.transform(0.0, -1.0, 1.0, 0.0, destinationX, destinationY + iHeight);
          renderStateContext.drawImageScaledFromSource(_source, 
              iLeft, iTop, iHeight, iWidth, 
              0, 0, iHeight, iWidth);
        }

        break;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  CanvasRenderingContext2D _getContext() {
    
    if (_context == null) {
      
      var canvas = new CanvasElement(width: _width, height: _height);

      _context = canvas.context2D;

      switch(_renderMode) {
        
        case 0:
          _context.drawImage(_source, _destinationX, _destinationY);
          break;
          
        case 1:
          _context.drawImageScaledFromSource(_source,
              _sourceX, _sourceY, _sourceWidth, _sourceHeight,
              _destinationX, _destinationY, _destinationWidth, _destinationHeight);
          break;

        case 2:
          _context.transform(0.0, -1.0, 1.0, 0.0, _destinationX, _destinationY + _destinationHeight);
          _context.drawImageScaledFromSource(_source, 
              _sourceX, _sourceY, _sourceHeight, _sourceWidth, 
              0.0 , 0.0, _destinationHeight, _destinationWidth);
          
          _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
          break;
      }

      _renderMode = 0;
      _destinationX = _sourceX = 0;
      _destinationY = _sourceY = 0;
      _destinationWidth = _sourceWidth = _width;
      _destinationHeight = _sourceHeight = _height;
      
      _source = canvas;
    }

    return _context;
  }

}
