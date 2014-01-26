part of stagexl;

/**
 * A vector graphics drawing surface.
 *
 * Example:
 *
 *     // draw a red circle
 *     var shape = new Shape();
 *     shape.graphics.circle(100, 100, 60);
 *     shape.graphics.fillColor(Color.Red);
 *     stage.addChild(shape);
 *
 * **Note:** Stroke and fill operations act on the *preceding* vector drawing operations.
 *
 * **Warning:** The WebGL backend does not support vector graphics yet.
 * If you want to draw Graphics display
 * objects please use the [DisplayObject.applyCache] method which renders the vector graphics
 * to a texture or do not opt-in for the WebGL renderer.
 *
 */
class Graphics {

  static final Map _BASE_64 = {"A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6,"H":7,"I":8,"J":9,"K":10,"L":11,"M":12,"N":13,"O":14,"P":15,"Q":16,"R":17,"S":18,"T":19,"U":20,"V":21,"W":22,"X":23,"Y":24,"Z":25,"a":26,"b":27,"c":28,"d":29,"e":30,"f":31,"g":32,"h":33,"i":34,"j":35,"k":36,"l":37,"m":38,"n":39,"o":40,"p":41,"q":42,"r":43,"s":44,"t":45,"u":46,"v":47,"w":48,"x":49,"y":50,"z":51,"0":52,"1":53,"2":54,"3":55,"4":56,"5":57,"6":58,"7":59,"8":60,"9":61,"+":62,"/":63};

  final List<_GraphicsCommand> _commands = new List<_GraphicsCommand>();

  Rectangle _identityRectangle = new Rectangle.zero();
  bool _identityRectangleRefresh = true;

  clear() {
    _commands.clear();
    _identityRectangleRefresh = true;
  }

  _addCommand(_GraphicsCommand command) {
    _commands.add(command);
    _identityRectangleRefresh = true;
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Start drawing a freeform path.
   *
   */
  beginPath() =>
    _addCommand(new _GraphicsCommandBeginPath());

  /**
   * Stop drawing a freeform path.
   */
  closePath() =>
    _addCommand(new _GraphicsCommandClosePath());

  /**
   * Moves the next point in the path to [x] and [y]
   */
  moveTo(num x, num y) =>
    _addCommand(new _GraphicsCommandMoveTo(x, y));

  /**
   * From the current point in the path, draw a line to [x] and [y]
   */
  lineTo(num x, num y) =>
    _addCommand(new _GraphicsCommandLineTo(x, y));

  /**
   * From the current point in the path, draw an arc to [endX] and [endY]
   */
  arcTo(num controlX, num controlY, num endX, num endY, num radius) =>
    _addCommand(new _GraphicsCommandArcTo(controlX, controlY, endX, endY, radius));

  /**
   * From the current point in the path, draw a quadratic curve to [endX] and [endY]
   */
  quadraticCurveTo(num controlX, num controlY, num endX, num endY) =>
    _addCommand(new _GraphicsCommandQuadraticCurveTo(controlX, controlY, endX, endY));

  /**
   * From the current point in the path, draw a bezier curve to [endX] and [endY]
   */
  bezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) =>
    _addCommand(new _GraphicsCommandBezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY));

  /**
   * Draw an arc at [x] and [y].
   */
  arc(num x, num y, num radius, num startAngle, num endAngle, bool antiClockwise) =>
    _addCommand(new _GraphicsCommandArc(x, y, radius, startAngle, endAngle, antiClockwise));

  /**
   * Draw a rectangle at [x] and [y]
   */
  rect(num x, num y, num width, num height) =>
    _addCommand(new _GraphicsCommandRect(x,y, width, height));

  /**
   * Apply a stroke color to the **previously drawn** vector object.
   */
  strokeColor(int color, [num width = 1.0, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
    _addCommand(new _GraphicsCommandStrokeColor(_color2rgba(color), width, joints, caps));

  /**
   * Apply a stroke color to the **previously drawn** vector object.
   */
  strokeGradient(GraphicsGradient gradient, [num width = 1.0, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
    _addCommand(new _GraphicsCommandStrokeGradient(gradient, width, joints, caps));

  /**
   * Apply a stroke pattern to the **previously drawn** vector object.
   */
  strokePattern(GraphicsPattern pattern, [num width = 1.0, String joints = JointStyle.ROUND, String caps = CapsStyle.ROUND]) =>
    _addCommand(new _GraphicsCommandStrokePattern(pattern, width, joints, caps));

  /**
   * Apply a fill color to the **previously drawn** vector object.
   */
  fillColor(int color) =>
    _addCommand(new _GraphicsCommandFillColor(_color2rgba(color)));

  /**
   * Apply a fill gradient to the **previously drawn** vector object.
   */
  fillGradient(GraphicsGradient gradient) =>
    _addCommand(new _GraphicsCommandFillGradient(gradient));

  /**
   * Apply a fill pattern to the **previously drawn** vector object.
   */
  fillPattern(GraphicsPattern pattern) =>
    _addCommand(new _GraphicsCommandFillPattern(pattern));

  //-------------------------------------------------------------------------------------------------

  /**
   * Draw a rounded rectangle at [x] and [y].
   */
  rectRound(num x, num y, num width, num height, num ellipseWidth, num ellipseHeight) {

    _addCommand(new _GraphicsCommandMoveTo(x + ellipseWidth, y));
    _addCommand(new _GraphicsCommandLineTo(x + width - ellipseWidth, y));
    _addCommand(new _GraphicsCommandQuadraticCurveTo(x + width, y, x + width, y + ellipseHeight));
    _addCommand(new _GraphicsCommandLineTo(x + width, y + height - ellipseHeight));
    _addCommand(new _GraphicsCommandQuadraticCurveTo(x + width, y + height, x + width - ellipseWidth, y + height));
    _addCommand(new _GraphicsCommandLineTo(x + ellipseWidth, y + height));
    _addCommand(new _GraphicsCommandQuadraticCurveTo(x, y + height, x, y + height - ellipseHeight));
    _addCommand(new _GraphicsCommandLineTo(x, y + ellipseHeight));
    _addCommand(new _GraphicsCommandQuadraticCurveTo(x, y, x + ellipseWidth, y));
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Draw a circle at [x] and [y]
   */
  circle(num x, num y, num radius) {

    _addCommand(new _GraphicsCommandMoveTo(x + radius, y));
    _addCommand(new _GraphicsCommandArc(x, y, radius, 0, PI * 2, false));
  }

  //-------------------------------------------------------------------------------------------------

  /**
   * Draw an ellipse at [x] and [y]
   */
  ellipse(num x, num y, num width, num height) {

    num kappa = 0.5522848;
    num ox = (width / 2) * kappa;
    num oy = (height / 2) * kappa;
    num x1 = x - width / 2;
    num y1 = y - height / 2;
    num x2 = x + width / 2;
    num y2 = y + height / 2;
    num xm = x;
    num ym = y;

    _addCommand(new _GraphicsCommandMoveTo(x1, ym));
    _addCommand(new _GraphicsCommandBezierCurveTo(x1, ym - oy, xm - ox, y1, xm, y1));
    _addCommand(new _GraphicsCommandBezierCurveTo(xm + ox, y1, x2, ym - oy, x2, ym));
    _addCommand(new _GraphicsCommandBezierCurveTo(x2, ym + oy, xm + ox, y2, xm, y2));
    _addCommand(new _GraphicsCommandBezierCurveTo(xm - ox, y2, x1, ym + oy, x1, ym));
  }

  //-------------------------------------------------------------------------------------------------

  decode(String str)  {

    var base64 = _BASE_64;
    var instructions = [moveTo, lineTo, quadraticCurveTo, bezierCurveTo, closePath];
    List<int> paramCount = [2, 2, 4, 6, 0];
    List<num> params = new List<num>();
    var x=0, y=0;
    var i=0, l=str.length;

    while (i<l) {
      var c = str[i];
      var n = base64[c];
      var fi = n>>3; // highest order bits 1-3 code for operation.
      var f = instructions[fi];
      // check that we have a valid instruction & that the unused bits are empty:
      if (f == null || (n&3) > 0)
        throw("bad path data (@$i): $c");
      var pl = paramCount[fi];
      if (fi == 0) x=y=0; // move operations reset the position.
      params.length = 0;
      i++;
      var charCount = (n>>2&1)+2;  // 4th header bit indicates number size for this operation.
      for (var p=0; p<pl; p++) {
        var v = base64[str[i]];
        var sign = (v>>5) > 0 ? -1 : 1;
        v = ((v&31)<<6)|(base64[str[i+1]]);
        if (charCount == 3) v = (v<<6)|(base64[str[i+2]]);
        v = sign*v/10;
        if (p%2 > 0) x = (v += x);
        else y = (v += y);
        params.add(v);
        i += charCount;
      }
      Function.apply(f, params);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Rectangle _getBoundsTransformed(Matrix matrix) {

    var bounds = new _GraphicsBounds(matrix);

    for(int i = 0; i < _commands.length; i++) {
      _commands[i].updateBounds(bounds);
    }

    return bounds.getRectangle();
  }

  //-------------------------------------------------------------------------------------------------

  bool _hitTestInput(num localX, num localY) {

    if (_identityRectangleRefresh) {
      _identityRectangleRefresh = false;
      _identityRectangle = _getBoundsTransformed(new Matrix.fromIdentity());
    }

    if (_identityRectangle.contains(localX, localY)) {

      var context = _dummyCanvasContext;
      context.setTransform(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
      context.beginPath();

      for(int i = 0; i < _commands.length; i++) {
        if (_commands[i].hitTestInput(context, localX, localY)) {
          return true;
        }
      }
    }

    return false;
  }

  //-------------------------------------------------------------------------------------------------

  void _drawPath(CanvasRenderingContext2D context) {

    for(int i = 0; i < _commands.length; i++) {
      _commands[i].drawPath(context);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void render(RenderState renderState) {

    var renderContext = renderState.renderContext;
    var matrix = renderState.globalMatrix;
    var alpha = renderState.globalAlpha;

    if (renderContext is RenderContextCanvas) {

      var context = renderContext.rawContext;
      context.setTransform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.globalAlpha = alpha;
      context.beginPath();

      for(int i = 0; i < _commands.length; i++) {
        _commands[i].render(context);
      }

    } else {

      // TODO: Native support for Graphics in WebGL will be added later.
      // For now please use the applyCache feature of DisplayObject.

    }
  }

}
