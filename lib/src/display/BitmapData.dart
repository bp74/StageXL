part of stagexl;

class BitmapData implements BitmapDrawable {
  
  int _width;
  int _height;
  bool _transparent;

  CanvasImageSource _source;
  CanvasRenderingContext2D _context;

  int _frameMode;
  int _frameOffsetX;
  int _frameOffsetY;
  int _frameX;
  int _frameY;
  int _frameWidth;
  int _frameHeight;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  BitmapData(int width, int height, [bool transparent = true, int fillColor = 0xFFFFFFFF]) {
    
    _width = width;
    _height = height;
    _transparent = transparent;
    
    var canvas = new CanvasElement(width: _width, height: _height);

    _context = canvas.context2d;
    _context.fillStyle = _transparent ? _color2rgba(fillColor) : _color2rgb(fillColor);
    _context.fillRect(0, 0, width, height);

    _source = canvas;
    _frameMode = 0;
    _frameOffsetX = 0;
    _frameOffsetY = 0;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromImageElement(ImageElement imageElement) {
    
    if (imageElement == null)
      throw new ArgumentError();
    
    _width = imageElement.naturalWidth;
    _height = imageElement.naturalHeight;
    _transparent = true;

    _source = imageElement;
    _frameMode = 0;
    _frameOffsetX = 0;
    _frameOffsetY = 0;
  }

  //-------------------------------------------------------------------------------------------------

  BitmapData.fromTextureAtlasFrame(TextureAtlasFrame textureAtlasFrame) {
    
    _width = textureAtlasFrame.originalWidth;
    _height = textureAtlasFrame.originalHeight;
    _transparent = true;

    _source = textureAtlasFrame.textureAtlas.imageElement;

    _frameMode = textureAtlasFrame.rotated ? 2 : 1;
    _frameOffsetX = textureAtlasFrame.offsetX;
    _frameOffsetY = textureAtlasFrame.offsetY;
    _frameX = textureAtlasFrame.frameX;
    _frameY = textureAtlasFrame.frameY;
    _frameWidth = textureAtlasFrame.frameWidth;
    _frameHeight = textureAtlasFrame.frameHeight;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  static Future<BitmapData> load(String url) {
    
    Completer<BitmapData> completer = new Completer<BitmapData>();

    var image = new ImageElement();
    image.onLoad.listen((event) => completer.complete(new BitmapData.fromImageElement(image)));
    image.onError.listen((event) => completer.completeError(new StateError("Error loading image.")));
    image.src = url;

    return completer.future;
  }

  @deprecated
  static Future<BitmapData> loadImage(String url) {
    return BitmapData.load(url);
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

    switch(_frameMode) {
      
      case 0:
        renderStateContext.drawImage(_source, _frameOffsetX, _frameOffsetY);
        break;

      case 1:
        renderStateContext.drawImageScaledFromSource(_source,
          _frameX, _frameY, _frameWidth, _frameHeight,
          _frameOffsetX, _frameOffsetY, _frameWidth, _frameHeight);
        break;

      case 2:
        renderStateContext.transform(0.0, -1.0, 1.0, 0.0, _frameOffsetX, _frameOffsetY + _frameHeight);
        renderStateContext.drawImageScaledFromSource(_source, 
          _frameX, _frameY, _frameHeight, _frameWidth, 0, 0, _frameHeight, _frameWidth);
        break;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void renderClipped(RenderState renderState, Rectangle clipRectangle) {
    
    var renderStateContext = renderState.context;
    
    if (clipRectangle.width <= 0.0 || clipRectangle.height <= 0.0)
      return;
    
    switch(_frameMode) {
      
      case 0:

        renderStateContext.drawImageScaledFromSource(_source, 
          clipRectangle.x - _frameOffsetX, clipRectangle.y - _frameOffsetY, clipRectangle.width, clipRectangle.height,
          clipRectangle.x + _frameOffsetX, clipRectangle.y + _frameOffsetY, clipRectangle.width, clipRectangle.height);
        
        break;

      case 1:

        var fLeft = _frameX;
        var fTop =  _frameY;
        var fRight = fLeft + _frameWidth;
        var fBottom = fTop + _frameHeight;

        var cLeft = _frameX - _frameOffsetX + clipRectangle.x;
        var cTop =  _frameY - _frameOffsetY + clipRectangle.y;
        var cRight = cLeft + clipRectangle.width;
        var cBottom = cTop + clipRectangle.height;

        var iLeft = (fLeft > cLeft) ? fLeft : cLeft;
        var iTop =  (fTop > cTop) ? fTop : cTop;
        var iRight = (fRight < cRight) ? fRight : cRight;
        var iBottom = (fBottom < cBottom) ? fBottom : cBottom;
        var iOffsetX = _frameOffsetX - fLeft + iLeft;
        var iOffsetY = _frameOffsetY - fTop + iTop;
        var iWidth = iRight - iLeft;
        var iHeight = iBottom - iTop;

        if (iWidth > 0.0 && iHeight > 0.0) {
          renderStateContext.drawImageScaledFromSource(_source, 
            iLeft, iTop, iWidth, iHeight, iOffsetX, iOffsetY, iWidth, iHeight);
        }

        break;

      case 2:

        var fLeft = _frameX;
        var fTop =  _frameY;
        var fRight = fLeft + _frameHeight;
        var fBottom = fTop + _frameWidth;

        var cLeft = _frameX + _frameOffsetY - clipRectangle.y + _frameHeight - clipRectangle.height;
        var cTop =  _frameY - _frameOffsetX + clipRectangle.x;
        var cRight = cLeft + clipRectangle.height;
        var cBottom = cTop + clipRectangle.width;

        var iLeft = (fLeft > cLeft) ? fLeft : cLeft;
        var iTop =  (fTop > cTop) ? fTop : cTop;
        var iRight = (fRight < cRight) ? fRight : cRight;
        var iBottom = (fBottom < cBottom) ? fBottom : cBottom;
        var iOffsetX = _frameOffsetX - fTop + iTop;
        var iOffsetY = _frameOffsetY + fRight - iRight;
        var iWidth = iBottom - iTop;
        var iHeight = iRight - iLeft;
        
        if (iWidth > 0.0 && iHeight > 0.0) {
          renderStateContext.transform(0.0, -1.0, 1.0, 0.0, iOffsetX, iOffsetY + iHeight);
          renderStateContext.drawImageScaledFromSource(_source, 
            iLeft, iTop, iHeight, iWidth, 0, 0, iHeight, iWidth);
        }

        break;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  CanvasRenderingContext2D _getContext() {
    
    if (_context == null) {
      
      var canvas = new CanvasElement(width: _width, height: _height);

      _context = canvas.context2d;

      switch(_frameMode) {
        
        case 0:
          _context.drawImage(_source, _frameOffsetX, _frameOffsetY);
          break;

        case 1:
          _context.drawImageScaledFromSource(_source, 
            _frameX, _frameY, _frameWidth, _frameHeight, 
            _frameOffsetX, _frameOffsetY, _frameWidth, _frameHeight);
          break;

        case 2:
          _context.setTransform(0.0, -1.0, 1.0, 0.0, _frameOffsetX, _frameOffsetY + _frameHeight);
          _context.drawImageScaledFromSource(_source, 
            _frameX, _frameY, _frameHeight, 
            _frameWidth, 0, 0, _frameHeight, _frameWidth);
          
          _context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
          break;
      }

      _source = canvas;
      _frameMode = 0;
      _frameOffsetX = 0;
      _frameOffsetY = 0;
    }

    return _context;
  }

}
