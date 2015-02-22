part of stagexl.display_ex;

/// A display object to show a section of a [BitmapData] according
/// to the [ratio] property.
///
/// Example:
///
///     var bitmapData = resourceManager.getBitmapData("loading");
///     var gauge = new Gauge(bitmapData, Gauge.DIRECTION_LEFT);
///     stage.addChild(gauge);
///
///     resourceManager.onProgress.listen((progress) => gauge.ratio = progress);

class Gauge extends DisplayObject {

  static const String DIRECTION_UP = 'DIRECTION_UP';
  static const String DIRECTION_RIGHT = 'DIRECTION_RIGHT';
  static const String DIRECTION_DOWN = 'DIRECTION_DOWN';
  static const String DIRECTION_LEFT = 'DIRECTION_LEFT';

  BitmapData bitmapData;
  String direction;

  num _ratio = 1.0;

  Gauge(this.bitmapData, [this.direction = DIRECTION_LEFT]) {

    var validDirection = false;
    validDirection = validDirection || direction == DIRECTION_UP;
    validDirection = validDirection || direction == DIRECTION_DOWN;
    validDirection = validDirection || direction == DIRECTION_LEFT;
    validDirection = validDirection || direction == DIRECTION_RIGHT;

    if (!validDirection) throw new ArgumentError('Invalid Gauge direction!');
  }

  //---------------------------------------------------------------------------

  num get ratio => _ratio;

  set ratio(num value) {
    if (value < 0.0) value = 0.0;
    if (value > 1.0) value = 1.0;
    _ratio = value;
  }

  //---------------------------------------------------------------------------

  @override
  Rectangle<num> get bounds {
    return bitmapData == null
      ? new Rectangle<num>(0.0, 0.0, 0.0 ,0.0)
      : new Rectangle<num>(0.0, 0.0, bitmapData.width, bitmapData.height);
  }

  @override
  DisplayObject hitTestInput(num localX, num localY) {
    if (bitmapData == null) return null;
    if (localX < 0.0 || localX >= bitmapData.width) return null;
    if (localY < 0.0 || localY >= bitmapData.height) return null;
    return this;
  }

  @override
  void render(RenderState renderState) {
    if (bitmapData != null) {
      var renderTextureQuad = _getRenderTextureQuad();
      renderState.renderQuad(renderTextureQuad);
    }
  }

  @override
  void renderFiltered(RenderState renderState) {
    if (bitmapData != null) {
      var renderTextureQuad = _getRenderTextureQuad();
      renderState.renderQuadFiltered(renderTextureQuad, this.filters);
    }
  }

  //---------------------------------------------------------------------------

  RenderTextureQuad _getRenderTextureQuad() {

    var width = bitmapData.width;
    var height = bitmapData.height;
    var left = 0;
    var top = 0;
    var right = width;
    var bottom = height;

    if (direction == DIRECTION_LEFT) left = ((1.0 - _ratio) * width).round();
    if (direction == DIRECTION_UP) top = ((1.0 - _ratio) * height).round();
    if (direction == DIRECTION_RIGHT) right = (_ratio * width).round();
    if (direction == DIRECTION_DOWN) bottom = (_ratio * height).round();

    var rectangle = new Rectangle(left, top, right - left, bottom - top);
    var renderTextureQuad = bitmapData.renderTextureQuad.clip(rectangle);

    return renderTextureQuad;
  }

}
