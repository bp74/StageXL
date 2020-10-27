part of stagexl.drawing;

/// A vector graphics drawing surface.
///
/// Example:
///
///     // draw a red circle
///     var shape = Shape();
///     shape.graphics.circle(100, 100, 60);
///     shape.graphics.fillColor(Color.Red);
///     stage.addChild(shape);
///
/// **Note:** Stroke and fill operations act on the *preceding* vector
/// drawing operations.

class Graphics {
  final List<GraphicsCommand> _originalCommands = <GraphicsCommand>[];
  final List<GraphicsCommand> _compiledCommands = <GraphicsCommand>[];

  Rectangle<num>? _bounds;

  //---------------------------------------------------------------------------

  /// Add a custom graphics command

  void addCommand(GraphicsCommand command) {
    command._setGraphics(this);
    _originalCommands.add(command);
    _invalidate();
  }

  /// Undo last graphics command

  void undoCommand() {
    if (_originalCommands.isNotEmpty) {
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
    var command = GraphicsCommandBeginPath();
    addCommand(command);
    return command;
  }

  /// Stop drawing a freeform path.
  GraphicsCommandClosePath closePath() {
    var command = GraphicsCommandClosePath();
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Moves the next point in the path to [x] and [y]
  GraphicsCommandMoveTo moveTo(num x, num y) {
    var command = GraphicsCommandMoveTo(x, y);
    addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a line to [x] and [y]
  GraphicsCommandLineTo lineTo(num x, num y) {
    var command = GraphicsCommandLineTo(x, y);
    addCommand(command);
    return command;
  }

  /// From the current point in the path, draw an arc to [endX] and [endY]
  GraphicsCommandArcTo arcTo(
      num controlX, num controlY, num endX, num endY, num radius) {
    var command = GraphicsCommandArcTo(controlX, controlY, endX, endY, radius);
    addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a quadratic curve to [endX] and [endY]
  GraphicsCommandQuadraticCurveTo quadraticCurveTo(
      num controlX, num controlY, num endX, num endY) {
    var command =
        GraphicsCommandQuadraticCurveTo(controlX, controlY, endX, endY);
    addCommand(command);
    return command;
  }

  /// From the current point in the path, draw a bezier curve to [endX] and [endY]
  GraphicsCommandBezierCurveTo bezierCurveTo(num controlX1, num controlY1,
      num controlX2, num controlY2, num endX, num endY) {
    var command = GraphicsCommandBezierCurveTo(
        controlX1, controlY1, controlX2, controlY2, endX, endY);
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Draw a rectangle at [x] and [y]
  GraphicsCommandRect rect(num x, num y, num width, num height) {
    var command = GraphicsCommandRect(x, y, width, height);
    addCommand(command);
    return command;
  }

  /// Draw a rounded rectangle at [x] and [y].
  GraphicsCommandRectRound rectRound(num x, num y, num width, num height,
      num ellipseWidth, num ellipseHeight) {
    var command = GraphicsCommandRectRound(
        x, y, width, height, ellipseWidth, ellipseHeight);
    addCommand(command);
    return command;
  }

  /// Draw an arc at [x] and [y].
  GraphicsCommandArc arc(num x, num y, num radius, num startAngle, num endAngle,
      [bool antiClockwise = false]) {
    var command =
        GraphicsCommandArc(x, y, radius, startAngle, endAngle, antiClockwise);
    addCommand(command);
    return command;
  }

  /// Draw an arc at [x] and [y].
  GraphicsCommandArcElliptical arcElliptical(double x, double y, double radiusX,
      double radiusY, double rotation, double startAngle, double endAngle,
      [bool antiClockwise = false]) {
    var command = GraphicsCommandArcElliptical(
        x, y, radiusX, radiusY, rotation, startAngle, endAngle, antiClockwise);
    addCommand(command);
    return command;
  }

  /// Draw a circle at [x] and [y]
  GraphicsCommandCircle circle(num x, num y, num radius,
      [bool antiClockwise = false]) {
    var command = GraphicsCommandCircle(x, y, radius, antiClockwise);
    addCommand(command);
    return command;
  }

  /// Draw an ellipse at [x] and [y]
  GraphicsCommandEllipse ellipse(num x, num y, num width, num height) {
    var command = GraphicsCommandEllipse(x, y, width, height);
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Apply a fill color to the **previously drawn** vector object.
  GraphicsCommandFillColor fillColor(int color) {
    var command = GraphicsCommandFillColor(color);
    addCommand(command);
    return command;
  }

  /// Apply a fill gradient to the **previously drawn** vector object.
  GraphicsCommandFillGradient fillGradient(GraphicsGradient gradient) {
    var command = GraphicsCommandFillGradient(gradient);
    addCommand(command);
    return command;
  }

  /// Apply a fill pattern to the **previously drawn** vector object.
  GraphicsCommandFillPattern fillPattern(GraphicsPattern pattern) {
    var command = GraphicsCommandFillPattern(pattern);
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Apply a stroke color to the **previously drawn** vector object.
  GraphicsCommandStrokeColor strokeColor(int color,
      [num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {
    var command =
        GraphicsCommandStrokeColor(color, width, jointStyle, capsStyle);
    addCommand(command);
    return command;
  }

  /// Apply a stroke color to the **previously drawn** vector object.
  GraphicsCommandStrokeGradient strokeGradient(GraphicsGradient gradient,
      [num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {
    var command =
        GraphicsCommandStrokeGradient(gradient, width, jointStyle, capsStyle);
    addCommand(command);
    return command;
  }

  /// Apply a stroke pattern to the **previously drawn** vector object.
  GraphicsCommandStrokePattern strokePattern(GraphicsPattern pattern,
      [num width = 1.0,
      JointStyle jointStyle = JointStyle.MITER,
      CapsStyle capsStyle = CapsStyle.NONE]) {
    var command =
        GraphicsCommandStrokePattern(pattern, width, jointStyle, capsStyle);
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------

  /// Decode the path that is encoded in the EaselJS format.
  /// Please use the [decodePath] method.

  @deprecated
  GraphicsCommandDecode decode(String text) {
    var command = GraphicsCommandDecodeEaselJS(text);
    addCommand(command);
    return command;
  }

  GraphicsCommandDecode decodePath(String path,
      [PathEncoding pathEncoding = PathEncoding.SVG]) {
    GraphicsCommandDecode command;
    if (pathEncoding == PathEncoding.EaselJS) {
      command = GraphicsCommandDecodeEaselJS(path);
    } else if (pathEncoding == PathEncoding.SVG) {
      command = GraphicsCommandDecodeSVG(path);
    } else {
      throw ArgumentError('Unknown path encoding.');
    }
    addCommand(command);
    return command;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  Rectangle<num> get bounds {
    if (_bounds == null) {
      var commands = _getCommands(true);
      var context = _GraphicsContextBounds();
      _updateContext(context, commands);
      _bounds = context.bounds;
    }
    return _bounds!.clone();
  }

  bool hitTest(num localX, num localY) {
    if (bounds.contains(localX, localY)) {
      var commands = _getCommands(true);
      var context = _GraphicsContextHitTest(localX, localY);
      _updateContext(context, commands);
      return context.hit;
    } else {
      return false;
    }
  }

  void render(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = _GraphicsContextCanvas(renderState);
      _updateContext(context, commands);
    } else {
      var commands = _getCommands(true);
      var context = _GraphicsContextRender(renderState);
      _updateContext(context, commands);
    }
  }

  void renderMask(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var context = _GraphicsContextCanvasMask(renderState);
      _updateContext(context, commands);
    } else {
      var commands = _getCommands(true);
      var context = GraphicsContextRenderMask(renderState);
      _updateContext(context, commands);
    }
  }

  //---------------------------------------------------------------------------

  List<GraphicsCommand> _getCommands(bool useCompiled) {
    if (useCompiled && _compiledCommands.isEmpty) {
      var context = _GraphicsContextCompiler(_compiledCommands);
      for (var c in _originalCommands) {
        c.updateContext(context);
      }
    }
    return useCompiled ? _compiledCommands : _originalCommands;
  }

  void _updateContext(GraphicsContext context, List<GraphicsCommand> commands) {
    for (var i = 0; i < commands.length; i++) {
      commands[i].updateContext(context);
    }
  }

  void _invalidate() {
    _compiledCommands.clear();
    _bounds = null;
  }
}
