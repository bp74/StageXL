part of stagexl.drawing.internal;

class GraphicsContextBounds extends GraphicsContext {

  Rectangle<num> bounds = new Rectangle<num>(0.0, 0.0, 0.0, 0.0);

  // TODO: implements bounds calculation.
  // TODO: we can make it much faster by implementing all methods.

  @override
  void fillColor(int color) {
    // check bounds of fill
  }

  @override
  void fillGradient(GraphicsGradient gradient) {
    // check bounds of fill
  }

  @override
  void fillPattern(GraphicsPattern pattern) {
    // check bounds of fill
  }

  @override
  void strokeColor(int color, double lineWidth, String lineJoin, String lineCap) {
    // check bounds of stroke
  }

  @override
  void strokeGradient(GraphicsGradient gradient, double lineWidth, String lineJoin, String lineCap) {
    // check bounds of stroke
  }

  @override
  void strokePattern(GraphicsPattern pattern, double lineWidth, String lineJoin, String lineCap) {
    // check bounds of stroke
  }

}
