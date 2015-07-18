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
    _updateBounds();
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    _updateBounds();
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    _updateBounds();
  }

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    _updateBounds();
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    _updateBounds();
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    _updateBounds();
  }

  //---------------------------------------------------------------------------

  void _updateBounds() {
    for(var segment in _path._segments) {
      _minX = _minX > segment.minX ? segment.minX : _minX;
      _minY = _minY > segment.minY ? segment.minY : _minY;
      _maxX = _maxX < segment.maxX ? segment.maxX : _maxX;
      _maxY = _maxY < segment.maxY ? segment.maxY : _maxY;
    }
  }

}
