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

  static const Map _BASE_64 = const {
    "A": 0,"B": 1,"C": 2,"D": 3,"E": 4,"F": 5,"G": 6,"H": 7,
    "I": 8,"J": 9,"K":10,"L":11,"M":12,"N":13,"O":14,"P":15,
    "Q":16,"R":17,"S":18,"T":19,"U":20,"V":21,"W":22,"X":23,
    "Y":24,"Z":25,"a":26,"b":27,"c":28,"d":29,"e":30,"f":31,
    "g":32,"h":33,"i":34,"j":35,"k":36,"l":37,"m":38,"n":39,
    "o":40,"p":41,"q":42,"r":43,"s":44,"t":45,"u":46,"v":47,
    "w":48,"x":49,"y":50,"z":51,"0":52,"1":53,"2":54,"3":55,
    "4":56,"5":57,"6":58,"7":59,"8":60,"9":61,"+":62,"/":63};

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

  void decode(String str) {
    var base64 = _BASE_64;
    var instructions = [moveTo, lineTo, quadraticCurveTo, bezierCurveTo, closePath];
    List<int> paramCount = [2, 2, 4, 6, 0];
    List<num> params = new List<num>();
    var x = 0.0, y = 0.0;
    var i = 0, l = str.length;

    while (i < l) {
      var c = str[i];
      var n = base64[c];
      // highest order bits 1-3 code for operation.
      var fi = n >> 3;
      var f = instructions[fi];
      // check that we have a valid instruction & that the unused bits are empty:
      if (f == null || (n & 3) > 0) {
        throw new StateError("bad path data (@$i): $c");
      }
      var pl = paramCount[fi];
      if (fi == 0) x = y = 0.0;
      // move operations reset the position.
      params.length = 0;
      i++;
      // 4th header bit indicates number size for this operation.
      var charCount = (n >> 2 & 1) + 2;
      for (var p = 0; p < pl; p++) {
        var v = base64[str[i]];
        var sign = (v >> 5) > 0 ? -1 : 1;
        v = ((v & 31) << 6) | (base64[str[i + 1]]);
        if (charCount == 3) v = (v << 6) | (base64[str[i + 2]]);
        var w = sign * v / 10;
        if (p % 2 > 0) x = (w += x); else y = (w += y);
        params.add(w);
        i += charCount;
      }
      Function.apply(f, params);
    }
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  Rectangle<num> get bounds {
    if (_bounds == null) {
      var commands = _getCommands(true);
      var graphicsContext = new GraphicsContextBounds();
      graphicsContext.applyGraphicsCommands(commands);
      _bounds = graphicsContext.bounds;
    }
    return _bounds;
  }

  bool hitTest(num localX, num localY) {
    if (this.bounds.contains(localX, localY)) {
      var commands = _getCommands(true);
      var graphicsContext = new GraphicsContextHitTest(localX, localY);
      graphicsContext.applyGraphicsCommands(commands);
      return graphicsContext.hit;
    } else {
      return false;
    }
  }

  void render(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var graphicsContext = new GraphicsContextCanvas(renderState);
      graphicsContext.applyGraphicsCommands(commands);
    } else {
      var commands = _getCommands(true);
      var graphicsContext = new GraphicsContextRender(renderState);
      graphicsContext.applyGraphicsCommands(commands);
    }
  }

  void renderMask(RenderState renderState) {
    if (renderState.renderContext is RenderContextCanvas) {
      var commands = _getCommands(false);
      var graphicsContext = new GraphicsContextCanvasMask(renderState);
      graphicsContext.applyGraphicsCommands(commands);
    } else {
      var commands = _getCommands(true);
      var graphicsContext = new GraphicsContextRenderMask(renderState);
      graphicsContext.applyGraphicsCommands(commands);
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
      var graphicsContext = new GraphicsContextCompiler(_compiledCommands);
      graphicsContext.applyGraphicsCommands(_originalCommands);
    }
    return useCompiled ? _compiledCommands : _originalCommands;
  }

}
