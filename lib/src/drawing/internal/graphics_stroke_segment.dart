part of stagexl.drawing;

class _GraphicsStrokeSegment extends _GraphicsMeshSegment {

  final _GraphicsStroke stroke;
  int _jointIndex1 = -1;
  int _jointIndex2 = -1;

  _GraphicsStrokeSegment(this.stroke, _GraphicsPathSegment pathSegment)
      : super(pathSegment.vertexCount * 4, pathSegment.vertexCount * 6) {

    _calculateStroke(pathSegment);
  }

  //---------------------------------------------------------------------------

  bool hitTest(double px, double py) {

    for (int i = 0; i < _indexCount - 2; i += 3) {

      var o1 = _indexBuffer[i + 0] * 2;
      var o2 = _indexBuffer[i + 1] * 2;
      var o3 = _indexBuffer[i + 2] * 2;

      var x1 = _vertexBuffer[o1 + 0] - px;
      var x2 = _vertexBuffer[o2 + 0] - px;
      var x3 = _vertexBuffer[o3 + 0] - px;
      if (x1 > 0 && x2 > 0 && x3 > 0) continue;
      if (x1 < 0 && x2 < 0 && x3 < 0) continue;

      var y1 = _vertexBuffer[o1 + 1] - py;
      var y2 = _vertexBuffer[o2 + 1] - py;
      var y3 = _vertexBuffer[o3 + 1] - py;
      if (y1 > 0 && y2 > 0 && y3 > 0) continue;
      if (y1 < 0 && y2 < 0 && y3 < 0) continue;

      var ab = x1 * y2 - x2 * y1;
      var bc = x2 * y3 - x3 * y2;
      var ca = x3 * y1 - x1 * y3;
      if (ab >= 0 && bc >= 0 && ca >= 0) return true;
      if (ab <= 0 && bc <= 0 && ca <= 0) return true;
    }

    return false;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _calculateStroke(_GraphicsPathSegment pathSegment) {

    var width = stroke.width;
    var jointStyle = stroke.jointStyle;
    var capsStyle = stroke.capsStyle;

    var vertices = pathSegment._vertexBuffer;
    var length = pathSegment.vertexCount;
    var closed = pathSegment.closed;

    if (pathSegment.closed && length >= 2) {
      var ax = pathSegment.firstVertexX;
      var ay = pathSegment.firstVertexY;
      var bx = pathSegment.lastVertexX;
      var by = pathSegment.lastVertexY;
      if (ax == bx && ay == by) length -= 1;
    }

    if (length <= 1) return;

    var v1x = 0.0, v1y = 0.0, v1l = 0.0;
    var n1x = 0.0, n1y = 0.0;
    var v2x = 0.0, v2y = 0.0, v2l = 0.0;
    var n2x = 0.0, n2y = 0.0;

    for (var i = -2; i <= length; i++) {

      // get next vertex
      var offset = ((i + 1) % length) * 2;
      v2x = vertices[offset + 0];
      v2y = vertices[offset + 1];

      // calculate next normal
      num vx = v2x - v1x;
      num vy = v1y - v2y;
      v2l = sqrt(vx * vx + vy * vy) / (0.5 * width);
      n2x = vy / v2l;
      n2y = vx / v2l;

      // calculate vertices
      if (i == 0 && closed == false) {
        _addCapStart(v1x, v1y, n2x, n2y, capsStyle);
      } else if (i == length - 1 && closed == false) {
        _addCapEnd(v1x, v1y, n1x, n1y, capsStyle);
      } else if (i >= 0 && (i < length || closed)) {
        _addJoint(v1x, v1y, v1l, v2l, n1x, n1y, n2x, n2y, jointStyle);
      }

      // shift vertices and normals
      v1x = v2x; v1y = v2y; v1l = v2l;
      n1x = n2x; n1y = n2y;
    }
  }

  //---------------------------------------------------------------------------

  void _addCapStart(double vx, double vy, num nx, num ny, CapsStyle capsStyle) {
    if (capsStyle == CapsStyle.SQUARE) {
      _jointIndex1 = this.addVertex(vx + nx - ny, vy + ny + nx);
      _jointIndex2 = this.addVertex(vx - nx - ny, vy - ny + nx);
    } else if (capsStyle == CapsStyle.ROUND) {
      _jointIndex1 = this.addVertex(vx + nx, vy + ny);
      _jointIndex2 = this.addVertex(vx - nx, vy - ny);
      _addArc(vx, vy, -nx, -ny, nx, ny, _jointIndex1, _jointIndex2, true);
    } else {
      _jointIndex1 = this.addVertex(vx + nx, vy + ny);
      _jointIndex2 = this.addVertex(vx - nx, vy - ny);
    }
  }

  //---------------------------------------------------------------------------

  void _addCapEnd(double vx, double vy, num nx, num ny, CapsStyle capsStyle) {
    int i1 = _jointIndex1, i2 = _jointIndex2;
    if (capsStyle == CapsStyle.SQUARE) {
      _jointIndex1 = this.addVertex(vx + nx + ny, vy + ny - nx);
      _jointIndex2 = this.addVertex(vx - nx + ny, vy - ny - nx);
    } else if (capsStyle == CapsStyle.ROUND) {
      _jointIndex1 = this.addVertex(vx + nx, vy + ny);
      _jointIndex2 = this.addVertex(vx - nx, vy - ny);
      _addArc(vx, vy, nx, ny, -nx, -ny, _jointIndex2, _jointIndex1, true);
    } else {
      _jointIndex1 = this.addVertex(vx + nx, vy + ny);
      _jointIndex2 = this.addVertex(vx - nx, vy - ny);
    }
    this.addIndices(i1, i2, _jointIndex1);
    this.addIndices(i2, _jointIndex1, _jointIndex2);
  }

  //---------------------------------------------------------------------------

  void _addJoint(
      double vx, double vy, num al, num bl, num ax, num ay, num bx, num by,
      JointStyle jointStyle) {

    num id = (bx * ay - by * ax);
    num it = (bx * (ax - bx) + by * (ay - by)) / id;
    num itAbs = it.abs();

    if (it.isNaN) {
      // a perfectly flat joint
      it = itAbs = 0.0;
    }

    if (jointStyle != JointStyle.MITER && itAbs < 0.10) {
      // overrule jointStyle in case of very flat joints
      jointStyle = JointStyle.MITER;
    }

    if (jointStyle == JointStyle.MITER && itAbs > 10.0) {
      // miter limit exceeded
      jointStyle = JointStyle.BEVEL;
    }

    var vmx = ax - it * ay; // miter-x
    var vmy = ay + it * ax; // miter-y
    bool isOverlap = itAbs > al || itAbs > bl;
    bool isCloseJoint = _jointIndex1 < 0;

    int i1 = it >= 0.0 ? _jointIndex1 : _jointIndex2;
    int i2 = it >= 0.0 ? _jointIndex2 : _jointIndex1;
    int i3 = 0, i4 = 0, i5 = 0;

    if (jointStyle == JointStyle.MITER) {

      if (isOverlap == false) {
        i3 = _jointIndex2;
        i4 = _jointIndex1 = this.addVertex(vx + vmx, vy + vmy);
        i5 = _jointIndex2 = this.addVertex(vx - vmx, vy - vmy);
      } else if (it >= 0.0) {
        i3 = this.addVertex(vx + ax, vy + ay);
        i4 = this.addVertex(vx - vmx, vy - vmy);
        i5 = _jointIndex2 = this.addVertex(vx - bx, vy - by);
        _jointIndex1 = this.addVertex(vx + bx, vy + by);
        this.addIndices(i1, i3, i4);
      } else {
        i3 = this.addVertex(vx - ax, vy - ay);
        i4 = this.addVertex(vx + vmx, vy + vmy);
        i5 = _jointIndex1 = this.addVertex(vx + bx, vy + by);
        _jointIndex2 = this.addVertex(vx - bx, vy - by);
        this.addIndices(i1, i3, i4);
      }

      this.addIndices(i1, i2, i4);
      this.addIndices(i3, i4, i5);

    } else if (jointStyle == JointStyle.BEVEL) {

      if (isOverlap == false && it >= 0.0) {
        i3 = _jointIndex1 = this.addVertex(vx + vmx, vy + vmy);
        i4 = this.addVertex(vx - ax, vy - ay);
        i5 = _jointIndex2 = this.addVertex(vx - bx, vy - by);
      } else if (isOverlap == false) {
        i3 = _jointIndex2 = this.addVertex(vx - vmx, vy - vmy);
        i4 = this.addVertex(vx + ax, vy + ay);
        i5 = _jointIndex1 = this.addVertex(vx + bx, vy + by);
      } else if (it >= 0.0) {
        i3 = this.addVertex(vx + ax, vy + ay);
        i4 = this.addVertex(vx - ax, vy - ay);
        i5 = _jointIndex2 = this.addVertex(vx - bx, vy - by);
        _jointIndex1 = this.addVertex(vx + bx, vy + by);
      } else {
        i3 = this.addVertex(vx - ax, vy - ay);
        i4 = this.addVertex(vx + ax, vy + ay);
        i5 = _jointIndex1 = this.addVertex(vx + bx, vy + by);
        _jointIndex2 = this.addVertex(vx - bx, vy - by);
      }

      this.addIndices(i1, i2, i3);
      this.addIndices(i2, i3, i4);
      this.addIndices(i3, i4, i5);

    } else if (jointStyle == JointStyle.ROUND) {

      if (isOverlap == false && it >= 0.0) {
        i3 = _jointIndex1 = this.addVertex(vx + vmx, vy + vmy);
        i4 = this.addVertex(vx - ax, vy - ay);
        _jointIndex2 = _addArc(vx, vy, -ax, -ay, -bx, -by, i3, i4, false);
      } else if (isOverlap == false) {
        i3 = _jointIndex2 = this.addVertex(vx - vmx, vy - vmy);
        i4 = this.addVertex(vx + ax, vy + ay);
        _jointIndex1 = _addArc(vx, vy, ax, ay, bx, by, i3, i4, true);
      } else if (it >= 0.0) {
        i3 = this.addVertex(vx + ax, vy + ay);
        i4 = this.addVertex(vx - ax, vy - ay);
        _jointIndex1 = this.addVertex(vx + bx, vy + by);
        _jointIndex2 = _addArc(vx, vy, -ax, -ay, -bx, -by, i3, i4, false);
      } else {
        i3 = this.addVertex(vx - ax, vy - ay);
        i4 = this.addVertex(vx + ax, vy + ay);
        _jointIndex2 = this.addVertex(vx - bx, vy - by);
        _jointIndex1 = _addArc(vx, vy, ax, ay, bx, by, i3, i4, true);
      }

      this.addIndices(i1, i2, i3);
      this.addIndices(i2, i3, i4);

    }

    if (isCloseJoint) {
      var x1 = _vertexBuffer[_jointIndex1 * 2 + 0];
      var y1 = _vertexBuffer[_jointIndex1 * 2 + 1];
      var x2 = _vertexBuffer[_jointIndex2 * 2 + 0];
      var y2 = _vertexBuffer[_jointIndex2 * 2 + 1];
      _vertexCount = 0;
      _indexCount = 0;
      _jointIndex1 = this.addVertex(x1, y1);
      _jointIndex2 = this.addVertex(x2, y2);
    }
  }

  //---------------------------------------------------------------------------

  int _addArc(
      num vx, num vy, num n1x, num n1y, num n2x, num n2y,
      int index1, int index2, bool antiClockwise) {

    num tau = 2.0 * PI;
    num startAngle = atan2(n1y, n1x);
    num endAngle = atan2(n2y, n2x);
    num start = (startAngle % tau);
    num delta = (endAngle % tau) - start;

    if (antiClockwise && endAngle > startAngle) {
      if (delta >= 0.0) delta -= tau;
    } else if (antiClockwise) {
      delta = (delta % tau) - tau;
    } else if (endAngle < startAngle) {
      if (delta <= 0.0) delta += tau;
    } else {
      delta %= tau;
    }

    int steps = (10 * delta / PI).abs().ceil();
    int index3 = index2;

    var cosR = cos(delta / steps);
    var sinR = sin(delta / steps);
    var tx = vx - vx * cosR + vy * sinR;
    var ty = vy - vx * sinR - vy * cosR;
    var ax = vx + n1x;
    var ay = vy + n1y;

    for (int s = 0; s < steps; s++) {
      num bx = ax * cosR - ay * sinR + tx;
      num by = ax * sinR + ay * cosR + ty;
      int index = this.addVertex(ax = bx, ay = by);
      this.addIndices(index1, index3, index);
      index3 = index;
    }

    return index3;
  }

}
