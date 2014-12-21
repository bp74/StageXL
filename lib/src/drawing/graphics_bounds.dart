part of stagexl.drawing;

class _GraphicsBounds {

  // cursor coordinates
  num cursorX = double.NAN;
  num cursorY = double.NAN;

  // path bounds
  num pathLeft = double.INFINITY;
  num pathRight = double.NEGATIVE_INFINITY;
  num pathTop = double.INFINITY;
  num pathBottom = double.NEGATIVE_INFINITY;

  // actual bounds
  num boundsLeft = double.INFINITY;
  num boundsRight = double.NEGATIVE_INFINITY;
  num boundsTop = double.INFINITY;
  num boundsBottom = double.NEGATIVE_INFINITY;

  //---------------------------------------------------------------

  bool get hasCursor =>
      !cursorX.isNaN && !cursorY.isNaN;

  bool get hasPath =>
      !pathLeft.isInfinite && !pathRight.isInfinite &&
      !pathTop.isInfinite && !pathBottom.isInfinite;

  bool get hasBounds =>
      !boundsLeft.isInfinite && !boundsRight.isInfinite &&
      !boundsTop.isInfinite && !boundsBottom.isInfinite;

  //---------------------------------------------------------------

  resetPath() {
    cursorX = cursorY = double.NAN;
    pathLeft = pathTop = double.INFINITY;
    pathRight = pathBottom = double.NEGATIVE_INFINITY;
  }

  updateCursor(num x, num y) {
    cursorX = x;
    cursorY = y;
  }

  updatePath(num x, num y) {
    if (hasCursor) {
      x = x.toDouble();
      y = y.toDouble();
      if (pathLeft > x) pathLeft = x;
      if (pathRight < x) pathRight = x;
      if (pathTop > y) pathTop = y;
      if (pathBottom < y) pathBottom = y;
    }
  }

  stroke(num lineWidth) {
    if (hasPath) {
      var lw = lineWidth / 2;
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
