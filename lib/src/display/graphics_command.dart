part of stagexl;

abstract class _GraphicsCommand {

  render(CanvasRenderingContext2D context);

  bool hitTestInput(CanvasRenderingContext2D context, num localX, num localY) {
    render(context);
    return false;
  }

  drawPath(CanvasRenderingContext2D context) {
    render(context);
  }

  updateBounds(_GraphicsBounds bounds) {
    // override if command has an effect on the bounds
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsBounds {

  Matrix matrix;

  // matrix tranformed coordinates
  num pathLeft = double.INFINITY;
  num pathRight = double.NEGATIVE_INFINITY;
  num pathTop = double.INFINITY;
  num pathBottom = double.NEGATIVE_INFINITY;
  num boundsLeft = double.INFINITY;
  num boundsRight = double.NEGATIVE_INFINITY;
  num boundsTop = double.INFINITY;
  num boundsBottom = double.NEGATIVE_INFINITY;

  // local coordinates
  num cursorX = double.NAN;
  num cursorY = double.NAN;

  _GraphicsBounds(this.matrix);

  //---------------------------------------------------------------

  bool get hasCursor => !cursorX.isNaN && !cursorY.isNaN;
  bool get hasPath => !pathLeft.isInfinite && !pathRight.isInfinite && !pathTop.isInfinite && !pathBottom.isInfinite;
  bool get hasBounds => !boundsLeft.isInfinite && !boundsRight.isInfinite && !boundsTop.isInfinite && !boundsBottom.isInfinite;

  resetPath() {
    cursorX = cursorY = double.NAN;
    pathLeft = pathTop = double.INFINITY;
    pathRight = pathBottom = double.NEGATIVE_INFINITY;
  }

  updateCursor(num x, num y) {
    cursorX = x;
    cursorY = y;
  }

  updatePath(num x, num y, [bool transformed = false]) {
    if (hasCursor) {
      x = x.toDouble();
      y = y.toDouble();
      num px = transformed ? x : x * matrix.a + y * matrix.c + matrix.tx;
      num py = transformed ? y : x * matrix.b + y * matrix.d + matrix.ty;

      if (pathLeft > px) pathLeft = px;
      if (pathRight < px) pathRight = px;
      if (pathTop > py) pathTop = py;
      if (pathBottom < py) pathBottom = py;
    }
  }

  stroke(num lineWidth) {
    if (hasPath) {
      var lw = sqrt(matrix.det) * lineWidth / 2;
      var left = pathLeft - lw;
      var right = pathRight + lw;
      var top = pathTop - lw;
      var bottom = pathBottom + lw;

      if (boundsLeft > left) boundsLeft = left;
      if (boundsRight < right) boundsRight = right;
      if (boundsTop > top) boundsTop = top;
      if (boundsBottom < bottom) boundsBottom = bottom;
    }
  }

  fill() {
    if (hasPath) {
      if (boundsLeft > pathLeft) boundsLeft = pathLeft;
      if (boundsRight < pathRight) boundsRight = pathRight;
      if (boundsTop > pathTop) boundsTop = pathTop;
      if (boundsBottom < pathBottom) boundsBottom = pathBottom;
    }
  }

  Rectangle<num> getRectangle() {
    if (hasBounds) {
      var boundsWidth = boundsRight - boundsLeft;
      var boundsHeight = boundsBottom - boundsTop;
      return new Rectangle<num>(boundsLeft, boundsTop, boundsWidth, boundsHeight);
    } else {
      return new Rectangle<num>(0.0, 0.0, 0.0, 0.0);
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

class _GraphicsCommandBeginPath extends _GraphicsCommand {

  _GraphicsCommandBeginPath();

  render(CanvasRenderingContext2D context) {
    context.beginPath();
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.resetPath();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandClosePath extends _GraphicsCommand {

  _GraphicsCommandClosePath();

  render(CanvasRenderingContext2D context) {
    context.closePath();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandMoveTo extends _GraphicsCommand {

  num _x, _y;

  _GraphicsCommandMoveTo(num x, num y) {
    _x = x.toDouble();
    _y = y.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.moveTo(_x, _y);
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.updateCursor(_x, _y);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandLineTo extends _GraphicsCommand {

  num _x, _y;

  _GraphicsCommandLineTo(num x, num y) {
    _x = x.toDouble();
    _y = y.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.lineTo(_x, _y);
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_x, _y);
    }

    bounds.updatePath(bounds.cursorX, bounds.cursorY);
    bounds.updatePath(_x, _y);
    bounds.updateCursor(_x, _y);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandArcTo extends _GraphicsCommand {

  num _controlX, _controlY;
  num _endX, _endY;
  num _radius;

  _GraphicsCommandArcTo(num controlX, num controlY, num endX, num endY, num radius) {
    _controlX = controlX.toDouble();
    _controlY = controlY.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
    _radius = radius.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.arcTo(_controlX, _controlY, _endX, _endY, _radius);
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor) {

      var v0 = new Vector(bounds.cursorX, bounds.cursorY);
      var v1 = new Vector(_controlX, _controlY);
      var v2 = new Vector(_endX, _endY);
      var v01 = v1 - v0;
      var v12 = v2 - v1;

      var rads = v01.rads - v12.rads;
      var tn = tan(rads / 2);
      var ra = (tn > 0) ? _radius : -_radius;
      var tangent1 = v1 - v01.scaleLength(tn * ra);
      var tangent2 = v1 + v12.scaleLength(tn * ra);
      var center = tangent1 + v01.normalLeft().scaleLength(ra);

      var angle1 = (tangent1 - center).rads;
      var angle2 = (tangent2 - center).rads;

      if (tn < 0) { // clockwise
        if (angle2 < angle1) angle2 = angle2 + 2 * PI;
      } else { // anti clockwise
        if (angle1 < angle2) angle1 = angle1 + 2 * PI;
      }

      var arc = tangent1 - center;
      var arcAngle = angle2 - angle1;
      var arcSteps = (arcAngle * 30).abs() ~/ PI + 1;

      bounds.updatePath(bounds.cursorX, bounds.cursorY);

      for (var i = 0; i <= arcSteps; i++) {
        var v = center + arc.rotate(i * arcAngle / arcSteps);
        bounds.updatePath(v.x, v.y);
      }

      bounds.updateCursor(tangent2.x, tangent2.y);
    } else {
      bounds.updateCursor(_controlX, _controlY);
    }
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandQuadraticCurveTo extends _GraphicsCommand {

  num _controlX, _controlY;
  num _endX, _endY;

  _GraphicsCommandQuadraticCurveTo(num controlX, num controlY, num endX, num endY) {
    _controlX = controlX.toDouble();
    _controlY = controlY.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.quadraticCurveTo(_controlX, _controlY, _endX, _endY);
  }

  // first derivative root finding for quadratic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  num _computeQuadraticBaseValue(num t, num a, num b, num c) {
    num mt = 1 - t;
    return mt * mt * a + 2 * mt * t * b + t * t * c;
  }

  num _computeQuadraticFirstDerivativeRoot(num a, num b, num c) {
    num t = -1;
    num denominator = a - 2 * b + c;
    return (denominator != 0) ? (a - b) / denominator : t;
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_controlX, _controlY);
    }

    var start = bounds.matrix.transformVector(new Vector(bounds.cursorX, bounds.cursorY));
    var control = bounds.matrix.transformVector(new Vector(_controlX, _controlY));
    var end = bounds.matrix.transformVector(new Vector(_endX, _endY));

    bounds.updatePath(start.x, start.y, true);

    num tx = _computeQuadraticFirstDerivativeRoot(start.x, control.x, end.x);
    num ty = _computeQuadraticFirstDerivativeRoot(start.y, control.y, end.y);
    num xm = (tx >= 0 && tx <= 1) ? _computeQuadraticBaseValue(tx, start.x, control.x, end.x) : start.x;
    num ym = (ty >= 0 && ty <= 1) ? _computeQuadraticBaseValue(ty, start.y, control.y, end.y) : start.y;

    bounds.updatePath(xm, ym, true);
    bounds.updatePath(end.x, end.y, true);
    bounds.updateCursor(_endX, _endY);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandBezierCurveTo extends _GraphicsCommand {

  num _controlX1, _controlY1;
  num _controlX2, _controlY2;
  num _endX, _endY;

  _GraphicsCommandBezierCurveTo(num controlX1, num controlY1, num controlX2, num controlY2, num endX, num endY) {
    _controlX1 = controlX1.toDouble();
    _controlY1 = controlY1.toDouble();
    _controlX2 = controlX2.toDouble();
    _controlY2 = controlY2.toDouble();
    _endX = endX.toDouble();
    _endY = endY.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.bezierCurveTo(_controlX1, _controlY1, _controlX2, _controlY2, _endX, _endY);
  }

  // first derivative root finding for cubic Bézier curves
  // http://processingjs.nihongoresources.com/bezierinfo/
  // http://processingjs.nihongoresources.com/bezierinfo/sketchsource.php?sketch=simpleQuadraticBezier

  num _computeCubicBaseValue(num t, num a, num b, num c, num d) {
    num mt = 1 - t;
    return mt * mt * mt * a + 3 * mt * mt * t * b + 3 * mt * t * t * c + t * t * t * d;
  }

  List<num> _computeCubicFirstDerivativeRoots(num a, num b, num c, num d) {

    num tl = -a + 2 * b - c;
    num tr = -sqrt(-a * (c - d) + b * b - b * (c + d) + c * c);
    num dn = -a + 3 * b - 3 * c + d;

    return (dn != 0) ? <num>[(tl + tr) / dn, (tl - tr) / dn] : <num>[-1, -1];
  }

  updateBounds(_GraphicsBounds bounds) {

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_controlX1, _controlY1);
    }

    var start = bounds.matrix.transformVector(new Vector(bounds.cursorX, bounds.cursorY));
    var control1 = bounds.matrix.transformVector(new Vector(_controlX1, _controlY1));
    var control2 = bounds.matrix.transformVector(new Vector(_controlX2, _controlY2));
    var end = bounds.matrix.transformVector(new Vector(_endX, _endY));

    // Workaround: if the control points have the same X or Y coordinate,
    // the derivative root calculations returns [-1, -1].
    //..moveTo(230, 150)..bezierCurveTo(250, 180, 320, 180, 340, 150)
    if (control1.x == control2.x) control1 = control1 + new Vector(0.0123, 0.0);
    if (control1.y == control2.y) control1 = control1 + new Vector(0.0, 0.0123);

    bounds.updatePath(start.x, start.y, true);

    List<num> txs = _computeCubicFirstDerivativeRoots(start.x, control1.x, control2.x, end.x);
    List<num> tys = _computeCubicFirstDerivativeRoots(start.y, control1.y, control2.y, end.y);

    for(int i = 0; i < 2; i++) {
      num tx = txs[i].toDouble();
      num ty = tys[i].toDouble();
      num xm = (tx >= 0 && tx <= 1) ? _computeCubicBaseValue(tx, start.x, control1.x, control2.x, end.x) : start.x;
      num ym = (ty >= 0 && ty <= 1) ? _computeCubicBaseValue(ty, start.y, control1.y, control2.y, end.y) : start.y;
      bounds.updatePath(xm, ym, true);
    }

    bounds.updatePath(end.x, end.y, true);
    bounds.updateCursor(_endX, _endY);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandArc extends _GraphicsCommand {

  num _x, _y, _radius;
  num _startAngle, _endAngle;
  bool _antiClockwise;

  _GraphicsCommandArc(num x, num y, num radius, num startAngle, num endAngle, bool antiClockwise) {
    _x = x.toDouble();
    _y = y.toDouble();
    _radius = radius.toDouble();
    _startAngle = startAngle.toDouble();
    _endAngle = endAngle.toDouble();
    _antiClockwise = antiClockwise;
  }

  render(CanvasRenderingContext2D context) {
    context.arc(_x, _y, _radius, _startAngle, _endAngle, _antiClockwise);
  }

  updateBounds(_GraphicsBounds bounds) {

    var initPoint = new Vector(_radius, 0);
    var startPoint = initPoint.rotate(_startAngle);
    var endPoint = initPoint.rotate(_endAngle);

    if (bounds.hasCursor == false) {
      bounds.updateCursor(_x + startPoint.x, _y + startPoint.y);
    }

    var angle1 = _startAngle;
    var angle2 = _endAngle;

    if (_antiClockwise) {
      if (angle1 < angle2) angle1 = angle1 + 2 * PI;
    } else {
      if (angle2 < angle1) angle2 = angle2 + 2 * PI;
    }

    var arcAngle = angle2 - angle1;
    var arcSteps = (arcAngle * 30).abs() ~/ PI + 1;

    bounds.updatePath(bounds.cursorX, bounds.cursorY);

    for(var i = 0; i <= arcSteps; i++) {
      var v = initPoint.rotate(angle1 + i * arcAngle / arcSteps);
      bounds.updatePath(_x + v.x, _y + v.y);
    }

    bounds.updateCursor(_x + endPoint.x, _y + endPoint.y);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandRect extends _GraphicsCommand {

  num _x, _y;
  num _width, _height;

  _GraphicsCommandRect(num x, num y, num width, num height) {
    _x = x.toDouble();
    _y = y.toDouble();
    _width = width.toDouble();
    _height = height.toDouble();
  }

  render(CanvasRenderingContext2D context) {
    context.rect(_x, _y, _width, _height);
  }

  updateBounds(_GraphicsBounds bounds) {

    bounds.updateCursor(_x, _y);
    bounds.updatePath(_x, _y);
    bounds.updatePath(_x + _width, _y);
    bounds.updatePath(_x + _width, _y + _height);
    bounds.updatePath(_x, _y + _height);
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

abstract class _GraphicsCommandStroke extends _GraphicsCommand {

  num _lineWidth;
  String _lineJoin;
  String _lineCap;

  _GraphicsCommandStroke(num lineWidth, String lineJoin, String lineCap) {
    _lineWidth = lineWidth.toDouble();
    _lineJoin = lineJoin;
    _lineCap = lineCap;
  }

  bool hitTestInput(CanvasRenderingContext2D context, num localX, num localY) {
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;

    try {
      return context.isPointInStroke(localX, localY);
    } catch (e) {
      return false;
    }
  }

  drawPath(CanvasRenderingContext2D context) {
    // no action
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.stroke(_lineWidth);
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandStrokeColor extends _GraphicsCommandStroke {

  String _color;

  _GraphicsCommandStrokeColor(String color,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _color = color;
  }

  render(CanvasRenderingContext2D context) {
    context.strokeStyle = _color;
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;
    context.stroke();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandStrokeGradient extends _GraphicsCommandStroke {

  GraphicsGradient _gradient;

  _GraphicsCommandStrokeGradient(GraphicsGradient gradient,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _gradient = gradient;
  }

  render(CanvasRenderingContext2D context) {
    context.strokeStyle = _gradient.getCanvasGradient(context);
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;
    context.stroke();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandStrokePattern extends _GraphicsCommandStroke {

  GraphicsPattern _pattern;

  _GraphicsCommandStrokePattern(GraphicsPattern pattern,
    num lineWidth, String lineJoin, String lineCap) : super (lineWidth, lineJoin, lineCap) {

    _pattern = pattern;
  }

  render(CanvasRenderingContext2D context) {
    context.strokeStyle = _pattern.getCanvasPattern(context);
    context.lineWidth = _lineWidth;
    context.lineJoin = _lineJoin;
    context.lineCap = _lineCap;

    var matrix = _pattern.matrix;

    if (matrix != null) {
      context.save();
      context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.stroke();
      context.restore();
    } else {
      context.stroke();
    }
  }
}

//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------

abstract class _GraphicsCommandFill extends _GraphicsCommand {

  bool hitTestInput(CanvasRenderingContext2D context, num localX, num localY) {
    return context.isPointInPath(localX, localY);
  }

  drawPath(CanvasRenderingContext2D context) {
    // no action
  }

  updateBounds(_GraphicsBounds bounds) {
    bounds.fill();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandFillColor extends _GraphicsCommandFill {

  String _color;

  _GraphicsCommandFillColor(String color) {
    _color = color;
  }

  render(CanvasRenderingContext2D context) {
    context.fillStyle = _color;
    context.fill();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandFillGradient extends _GraphicsCommandFill {

  GraphicsGradient _gradient;

  _GraphicsCommandFillGradient(GraphicsGradient gradient) {
    _gradient = gradient;
  }

  render(CanvasRenderingContext2D context) {
    context.fillStyle = _gradient.getCanvasGradient(context);
    context.fill();
  }
}

//-------------------------------------------------------------------------------------------------

class _GraphicsCommandFillPattern extends _GraphicsCommandFill {

  GraphicsPattern _pattern;

  _GraphicsCommandFillPattern(GraphicsPattern pattern) {
    _pattern = pattern;
  }

  render(CanvasRenderingContext2D context) {

    context.fillStyle = _pattern.getCanvasPattern(context);
    var matrix = _pattern.matrix;

    if (matrix != null) {
      context.save();
      context.transform(matrix.a, matrix.b, matrix.c, matrix.d, matrix.tx, matrix.ty);
      context.fill();
      context.restore();
    } else {
      context.fill();
    }
  }
}

