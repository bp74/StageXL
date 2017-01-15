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

class Graphics {

  final List<GraphicsCommand> _originalCommands = new List<GraphicsCommand>();
  final List<GraphicsCommand> _compiledCommands = new List<GraphicsCommand>();

  Rectangle<num> _bounds;

  //---------------------------------------------------------------------------

  /// Add a custom graphics command

  void addCommand(GraphicsCommand command) {
    command._setGraphics(this);
    _originalCommands.add(command);
    _invalidate();
  }

  /// Undo last graphics command

  void undoCommand() {
    if (_originalCommands.length > 0) {
      _originalCommands.removeLast();
      _invalidate();
    }
  }

  /// Clear all previously added graphics commands.

  void clear() {
    for (var c in _originalCommands) {
      c._setGraphics(null);
    }
    _originalCommands.clear();
    _invalidate();
  }

  //---------------------------------------------------------------------------

  /// Start drawing a freeform path.
  GraphicsCommandBeginPath beginPath() {
    var command = new GraphicsCommandBeginPath();
    this.addCommand(command);
    return command;
  }

  /// Stop drawing a freeform path.
  GraphicsCommandClosePath closePath() {
    var command = new GraphicsCommandClosePath();
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Moves the next point in the path to [x] and [y]
  GraphicsCommandMoveTo moveTo(num x, num y) {
    var command = new GraphicsCommandMoveTo(x, y);
    this.addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a line to [x] and [y]
  GraphicsCommandLineTo lineTo(num x, num y) {
    var command = new GraphicsCommandLineTo(x, y);
    this.addCommand(command);
    return command;
  }

  /// From the current point in the path, draw an arc to [endX] and [endY]
  GraphicsCommandArcTo arcTo(num controlX, num controlY, num endX, num endY, num radius) {
    var command = new GraphicsCommandArcTo(controlX, controlY, endX, endY, radius);
    this.addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a quadratic curve to [endX] and [endY]
  GraphicsCommandQuadraticCurveTo quadraticCurveTo(num controlX, num controlY, num endX, num endY) {
    var command = new GraphicsCommandQuadraticCurveTo(controlX, controlY, endX, endY);
    this.addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a bezier curve to [endX] and [endY]
  GraphicsCommandBezierCurveTo bezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) {
    var command = new GraphicsCommandBezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Draw a rectangle at [x] and [y]
  GraphicsCommandRect rect(num x, num y, num width, num height) {
    var command = new GraphicsCommandRect(x, y, width, height);
    this.addCommand(command);
    return command;
  }

  /// Draw a rounded rectangle at [x] and [y].
  GraphicsCommandRectRound rectRound(num x, num y, num width, num height, num ellipseWidth, num ellipseHeight) {
    var command = new GraphicsCommandRectRound(x, y, width, height, ellipseWidth, ellipseHeight);
    this.addCommand(command);
    return command;
  }

  /// Draw an arc at [x] and [y].
  GraphicsCommandArc arc(num x, num y, num radius, num startAngle, num endAngle, [bool antiClockwise = false]) {
    var command = new GraphicsCommandArc(x, y, radius, startAngle, endAngle, antiClockwise);
    this.addCommand(command);
    return command;
  }

  /// Draw an arc at [x] and [y].
  GraphicsCommandArcElliptical arcElliptical(
      double x, double y, double radiusX, double radiusY, double rotation,
      double startAngle, double endAngle, [bool antiClockwise = false]) {
    var command = new GraphicsCommandArcElliptical(
        x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
    this.addCommand(command);
    return command;
  }

  /// Draw a circle at [x] and [y]
  GraphicsCommandCircle circle(num x, num y, num radius, [bool antiClockwise = false]) {
    var command = new GraphicsCommandCircle(x, y, radius, antiClockwise);
    this.addCommand(command);
    return command;
  }

  /// Draw an ellipse at [x] and [y]
  GraphicsCommandEllipse ellipse(num x, num y, num width, num height) {
    var command = new GraphicsCommandEllipse(x, y, width, height);
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Apply a fill color to the **previously drawn** vector object.
  GraphicsCommandFillColor fillColor(int color) {
    var command = new GraphicsCommandFillColor(color);
    this.addCommand(command);
    return command;
  }

  /// Apply a fill gradient to the **previously drawn** vector object.
  GraphicsCommandFillGradient fillGradient(GraphicsGradient gradient) {
    var command = new GraphicsCommandFillGradient(gradient);
    this.addCommand(command);
    return command;
  }

  /// Apply a fill pattern to the **previously drawn** vector object.
  GraphicsCommandFillPattern fillPattern(GraphicsPattern pattern) {
    var command = new GraphicsCommandFillPattern(pattern);
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Apply a stroke color to the **previously drawn** vector object.
  GraphicsCommandStrokeColor strokeColor(int color, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    var command = new GraphicsCommandStrokeColor(color, width, jointStyle, capsStyle);
    this.addCommand(command);
    return command;
  }

  /// Apply a stroke color to the **previously drawn** vector object.
  GraphicsCommandStrokeGradient strokeGradient(GraphicsGradient gradient, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    var command = new GraphicsCommandStrokeGradient(gradient, width, jointStyle, capsStyle);
    this.addCommand(command);
    return command;
  }

  /// Apply a stroke pattern to the **previously drawn** vector object.
  GraphicsCommandStrokePattern strokePattern(GraphicsPattern pattern, [
      num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {

    var command = new GraphicsCommandStrokePattern(pattern, width, jointStyle, capsStyle);
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Decode the path that is encoded in the EaselJS format.
  /// Please use the new [decodePath] method.

  @deprecated
  GraphicsCommandDecode decode(String text) {
    var command = new GraphicsCommandDecodeEaselJS(text);
    this.addCommand(command);
    return command;
  }

  GraphicsCommandDecode decodePath(String path, [PathEncoding pathEncoding = PathEncoding.SVG]) {
    GraphicsCommandDecode command;
    if (pathEncoding == PathEncoding.EaselJS) {
      command = new GraphicsCommandDecodeEaselJS(path);
    } else if (pathEncoding == PathEncoding.SVG) {
      command = new GraphicsCommandDecodeSVG(path);
    } else {
      throw new ArgumentError("Unknown path encoding.");
    }
    this.addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  Rectangle<num> get bounds {
    if (_bounds == null) {
      var commands = _getCommands(true);
      var context = new _GraphicsContextBounds();
      _updateContext(context, commands);
      _bounds = context.bounds;
    }
    return _bounds.clone();
  }

  bool hitTest(num localX, num localY) {
    if (this.bounds.contains(localX, localY)) {
      var commands = _getCommands(true);
      var context = new _GraphicsContextHitTest(localX, localY);
      _updateContext(context, commands);
      return context.hit;
    } else {
      return false;
    }
  }

  void render(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = new _GraphicsContextCanvas(renderState);
      _updateContext(context, commands);
    } else {
      var commands = _getCommands(true);
      var context = new _GraphicsContextRender(renderState);
      _updateContext(context, commands);
    }
  }

  void renderMask(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = new _GraphicsContextCanvasMask(renderState);
      _updateContext(context, commands);
    } else {
      var commands = _getCommands(true);
      var context = new GraphicsContextRenderMask(renderState);
      _updateContext(context, commands);
    }
  }

  //---------------------------------------------------------------------------

  List<GraphicsCommand> _getCommands(bool useCompiled) {
    if (useCompiled && _compiledCommands.isEmpty) {
      var context = new _GraphicsContextCompiler(_compiledCommands);
      for (var c in _originalCommands) {
        c.updateContext(context);
      }
    }
    return useCompiled ? _compiledCommands : _originalCommands;
  }

  void _updateContext(GraphicsContext context, List<GraphicsCommand> commands) {
    for (int i = 0; i < commands.length; i++) {
      commands[i].updateContext(context);
    }
  }

  void _invalidate() {
    _compiledCommands.clear();
    _bounds = null;
  }

}
