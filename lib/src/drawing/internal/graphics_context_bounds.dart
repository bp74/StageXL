part of stagexl.drawing.internal;

class GraphicsContextBounds extends GraphicsContext {

  double _minX = 0.0 + double.MAX_FINITE;
  double _minY = 0.0 + double.MAX_FINITE;
  double _maxX = 0.0 - double.MAX_FINITE;
  double _maxY = 0.0 - double.MAX_FINITE;

  //---------------------------------------------------------------------------

  double get minX => _minX;
  double get minY => _minY;
  double get maxX => _maxX;
  double get maxY => _maxY;

  Rectangle<num> get bounds {
    if (minX < maxX && minY < maxY) {
      return new Rectangle<double>(minX, minY, maxX - minX, maxY - minY);
    } else {
      return new Rectangle<double>(0.0, 0.0, 0.0, 0.0);
    }
  }

  //---------------------------------------------------------------------------

  @override
  void fillColor(int color) {
    _updateBoundsForFill();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _updateBoundsForFill();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _updateBoundsForFill();
  }

  @override
  void strokeColor(int color, double width, String jointStyle, String capsStyle) {
    _updateBoundsForStroke();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double width, String jointStyle, String capsStyle) {
    _updateBoundsForStroke();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double width, String jointStyle, String capsStyle) {
    _updateBoundsForStroke();
  }

  //---------------------------------------------------------------------------

  void _updateBoundsForFill() {
    for(var segment in _path.segments) {
      _minX = _minX > segment.minX ? segment.minX : _minX;
      _minY = _minY > segment.minY ? segment.minY : _minY;
      _maxX = _maxX < segment.maxX ? segment.maxX : _maxX;
      _maxY = _maxY < segment.maxY ? segment.maxY : _maxY;
    }
  }

  void _updateBoundsForStroke() {
    var stroke = _stroke ?? new GraphicsStroke(_path, _command);
    for(var segment in stroke.segments) {
      _minX = _minX > segment.minX ? segment.minX : _minX;
      _minY = _minY > segment.minY ? segment.minY : _minY;
      _maxX = _maxX < segment.maxX ? segment.maxX : _maxX;
      _maxY = _maxY < segment.maxY ? segment.maxY : _maxY;
    }
  }

}
