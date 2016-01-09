part of stagexl.drawing;

/// A vector graphics drawing surface.
///
/// Example:
///
///     // draw a red circle
///     var shape = new Shape();
///     shape.graphics.circle(100, 100, 60);
///     shape.graphics.fillColor(Color.Red);
///     stage.addChild(shape);
///
/// **Note:** Stroke and fill operations act on the *preceding* vector
/// drawing operations.
///
/// **Warning:** The WebGL backend does not support vector graphics yet.
/// If you want to draw Graphics display objects please use the
/// [DisplayObject.applyCache] method which renders the vector graphics
/// to a texture or do not opt-in for the WebGL renderer.

class Graphics {

  final List<GraphicsCommand> _originalCommands = new List<GraphicsCommand>();
  final List<GraphicsCommand> _compiledCommands = new List<GraphicsCommand>();

  Rectangle<num> _bounds = null;

  //---------------------------------------------------------------------------

  /// Clear all previously added graphics commands.
  void clear() {
    _originalCommands.clear();
    _compiledCommands.clear();
  }

  /// Start drawing a freeform path.
  void beginPath() {
    _addCommand(new GraphicsCommandBeginPath());
  }

  /// Stop drawing a freeform path.
  void closePath() {
    _addCommand(new GraphicsCommandClosePath());
  }

  //---------------------------------------------------------------------------

  /// Moves the next point in the path to [x] and [y]
  void moveTo(num x, num y) {
    _addCommand(new GraphicsCommandMoveTo(x, y));
  }

  /// From the current point in the path, draw a line to [x] and [y]
  void lineTo(num x, num y) {
    _addCommand(new GraphicsCommandLineTo(x, y));
  }

  /// From the current point in the path, draw an arc to [endX] and [endY]
  void arcTo(num controlX, num controlY, num endX, num endY, num radius) {
    _addCommand(new GraphicsCommandArcTo(controlX, controlY, endX, endY, radius));
  }

  /// From the current point in the path, draw a quadratic curve to [endX] and [endY]
  void quadraticCurveTo(num controlX, num controlY, num endX, num endY) {
    _addCommand(new GraphicsCommandQuadraticCurveTo(controlX, controlY, endX, endY));
  }

  /// From the current point in the path, draw a bezier curve to [endX] and [endY]
  void bezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) {
    _addCommand(new GraphicsCommandBezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY));
  }

  //---------------------------------------------------------------------------

  /// Draw a rectangle at [x] and [y]
  void rect(num x, num y, num width, num height) {
    _addCommand(new GraphicsCommandRect(x, y, width, height));
  }

  /// Draw a rounded rectangle at [x] and [y].
  void rectRound(num x, num y, num width, num height, num ellipseWidth, num ellipseHeight) {
    _addCommand(new GraphicsCommandRectRound(x, y, width, height, ellipseWidth, ellipseHeight));
  }

  /// Draw an arc at [x] and [y].
  void arc(num x, num y, num radius, num startAngle, num endAngle, [bool antiClockwise = false]) {
    _addCommand(new GraphicsCommandArc(x, y, radius, startAngle, endAngle, antiClockwise));
  }

  /// Draw a circle at [x] and [y]
  void circle(num x, num y, num radius, [bool antiClockwise = false]) {
    _addCommand(new GraphicsCommandCircle(x, y, radius, antiClockwise));
  }

  /// Draw an ellipse at [x] and [y]
  void ellipse(num x, num y, num width, num height) {
    _addCommand(new GraphicsCommandEllipse(x, y, width, height));
  }

  //---------------------------------------------------------------------------

  /// Apply a fill color to the **previously drawn** vector object.
  void fillColor(int color) {
    _addCommand(new GraphicsCommandFillColor(color));
  }

  /// Apply a fill gradient to the **previously drawn** vector object.
  void fillGradient(GraphicsGradient gradient) {
    _addCommand(new GraphicsCommandFillGradient(gradient));
  }

  /// Apply a fill pattern to the **previously drawn** vector object.
  void fillPattern(GraphicsPattern pattern) {
    _addCommand(new GraphicsCommandFillPattern(pattern));
  }

  //---------------------------------------------------------------------------

  /// Apply a stroke color to the **previously drawn** vector object.
  void strokeColor(int color, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    _addCommand(new GraphicsCommandStrokeColor(color, width, jointStyle, capsStyle));
  }

  /// Apply a stroke color to the **previously drawn** vector object.
  void strokeGradient(GraphicsGradient gradient, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    _addCommand(new GraphicsCommandStrokeGradient(gradient, width, jointStyle, capsStyle));
  }

  /// Apply a stroke pattern to the **previously drawn** vector object.
  void strokePattern(GraphicsPattern pattern, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    _addCommand(new GraphicsCommandStrokePattern(pattern, width, jointStyle, capsStyle));
  }

  //---------------------------------------------------------------------------

  void decode(String text) {
    _addCommand(new GraphicsCommandDecode(text));
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  Rectangle<num> get bounds {
    if (_bounds == null) {
      var commands = _getCommands(true);
      var context = new GraphicsContextBounds();
      commands.forEach((c) => c.updateContext(context));
      _bounds = context.bounds;
    }
    return _bounds;
  }

  bool hitTest(num localX, num localY) {
    if (this.bounds.contains(localX, localY)) {
      var commands = _getCommands(true);
      var context = new GraphicsContextHitTest(localX, localY);
      commands.forEach((c) => c.updateContext(context));
      return context.hit;
    } else {
      return false;
    }
  }

  void render(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = new GraphicsContextCanvas(renderState);
      commands.forEach((c) => c.updateContext(context));
    } else {
      var commands = _getCommands(true);
      var context = new GraphicsContextRender(renderState);
      commands.forEach((c) => c.updateContext(context));
    }
  }

  void renderMask(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = new GraphicsContextCanvasMask(renderState);
      commands.forEach((c) => c.updateContext(context));
    } else {
      var commands = _getCommands(true);
      var context = new GraphicsContextRenderMask(renderState);
      commands.forEach((c) => c.updateContext(context));
    }
  }

  //---------------------------------------------------------------------------

  void _addCommand(GraphicsCommand command) {
    _originalCommands.add(command);
    _compiledCommands.clear();
    _bounds = null;
  }

  List<GraphicsCommand> _getCommands(bool useCompiled) {
    if (useCompiled && _compiledCommands.length == 0) {
      var context = new GraphicsContextCompiler(_compiledCommands);
      _originalCommands.forEach((c) => c.updateContext(context));
    }
    return useCompiled ? _compiledCommands : _originalCommands;
  }

}
