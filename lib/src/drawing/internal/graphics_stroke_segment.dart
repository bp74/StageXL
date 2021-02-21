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
    for (var i = 0; i < _indexCount - 2; i += 3) {
      final o1 = _indexBuffer[i + 0] * 2;
      final o2 = _indexBuffer[i + 1] * 2;
      final o3 = _indexBuffer[i + 2] * 2;

      final x1 = _vertexBuffer[o1 + 0] - px;
      final x2 = _vertexBuffer[o2 + 0] - px;
      final x3 = _vertexBuffer[o3 + 0] - px;
      if (x1 > 0 && x2 > 0 && x3 > 0) continue;
      if (x1 < 0 && x2 < 0 && x3 < 0) continue;

      final y1 = _vertexBuffer[o1 + 1] - py;
      final y2 = _vertexBuffer[o2 + 1] - py;
      final y3 = _vertexBuffer[o3 + 1] - py;
      if (y1 > 0 && y2 > 0 && y3 > 0) continue;
      if (y1 < 0 && y2 < 0 && y3 < 0) continue;

      final ab = x1 * y2 - x2 * y1;
      final bc = x2 * y3 - x3 * y2;
      final ca = x3 * y1 - x1 * y3;
      if (ab >= 0 && bc >= 0 && ca >= 0) return true;
      if (ab <= 0 && bc <= 0 && ca <= 0) return true;
    }

    return false;
  }

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  void _calculateStroke(_GraphicsPathSegment pathSegment) {
    final width = stroke.width;
    final jointStyle = stroke.jointStyle;
    final capsStyle = stroke.capsStyle;

    final vertices = pathSegment._vertexBuffer;
    var length = pathSegment.vertexCount;
    final closed = pathSegment.closed;

    if (pathSegment.closed && length >= 2) {
      final ax = pathSegment.firstVertexX;
      final ay = pathSegment.firstVertexY;
      final bx = pathSegment.lastVertexX;
      final by = pathSegment.lastVertexY;
      if (ax == bx && ay == by) length -= 1;
    }

    if (length <= 1) return;

    var v1x = 0.0, v1y = 0.0, v1l = 0.0;
    var n1x = 0.0, n1y = 0.0;
    var v2x = 0.0, v2y = 0.0, v2l = 0.0;
    var n2x = 0.0, n2y = 0.0;

    for (var i = -2; i <= length; i++) {
      // get next vertex
      final offset = ((i + 1) % length) * 2;
      v2x = vertices[offset + 0];
      v2y = vertices[offset + 1];

      // calculate next normal
      final num vx = v2x - v1x;
      final num vy = v1y - v2y;
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
      v1x = v2x;
      v1y = v2y;
      v1l = v2l;
      n1x = n2x;
      n1y = n2y;
    }
  }

  //---------------------------------------------------------------------------

  void _addCapStart(double vx, double vy, num nx, num ny, CapsStyle capsStyle) {
    if (capsStyle == CapsStyle.SQUARE) {
      _jointIndex1 = addVertex(vx + nx - ny, vy + ny + nx);
      _jointIndex2 = addVertex(vx - nx - ny, vy - ny + nx);
    } else if (capsStyle == CapsStyle.ROUND) {
      _jointIndex1 = addVertex(vx + nx, vy + ny);
      _jointIndex2 = addVertex(vx - nx, vy - ny);
      _addArc(vx, vy, -nx, -ny, nx, ny, _jointIndex1, _jointIndex2, true);
    } else {
      _jointIndex1 = addVertex(vx + nx, vy + ny);
      _jointIndex2 = addVertex(vx - nx, vy - ny);
    }
  }

  //---------------------------------------------------------------------------

  void _addCapEnd(double vx, double vy, num nx, num ny, CapsStyle capsStyle) {
    final i1 = _jointIndex1, i2 = _jointIndex2;
    if (capsStyle == CapsStyle.SQUARE) {
      _jointIndex1 = addVertex(vx + nx + ny, vy + ny - nx);
      _jointIndex2 = addVertex(vx - nx + ny, vy - ny - nx);
    } else if (capsStyle == CapsStyle.ROUND) {
      _jointIndex1 = addVertex(vx + nx, vy + ny);
      _jointIndex2 = addVertex(vx - nx, vy - ny);
      _addArc(vx, vy, nx, ny, -nx, -ny, _jointIndex2, _jointIndex1, true);
    } else {
      _jointIndex1 = addVertex(vx + nx, vy + ny);
      _jointIndex2 = addVertex(vx - nx, vy - ny);
    }
    addIndices(i1, i2, _jointIndex1);
    addIndices(i2, _jointIndex1, _jointIndex2);
  }

  //---------------------------------------------------------------------------

  void _addJoint(double vx, double vy, num al, num bl, num ax, num ay, num bx,
      num by, JointStyle jointStyle) {
    final id = bx * ay - by * ax;
    var it = (bx * (ax - bx) + by * (ay - by)) / id;
    var itAbs = it.abs();

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

    final vmx = ax - it * ay; // miter-x
    final vmy = ay + it * ax; // miter-y
    final isOverlap = itAbs > al || itAbs > bl;
    final isCloseJoint = _jointIndex1 < 0;

    final i1 = it >= 0.0 ? _jointIndex1 : _jointIndex2;
    final i2 = it >= 0.0 ? _jointIndex2 : _jointIndex1;
    var i3 = 0, i4 = 0, i5 = 0;

    if (jointStyle == JointStyle.MITER) {
      if (isOverlap == false) {
        i3 = _jointIndex2;
        i4 = _jointIndex1 = addVertex(vx + vmx, vy + vmy);
        i5 = _jointIndex2 = addVertex(vx - vmx, vy - vmy);
      } else if (it >= 0.0) {
        i3 = addVertex(vx + ax, vy + ay);
        i4 = addVertex(vx - vmx, vy - vmy);
        i5 = _jointIndex2 = addVertex(vx - bx, vy - by);
        _jointIndex1 = addVertex(vx + bx, vy + by);
        addIndices(i1, i3, i4);
      } else {
        i3 = addVertex(vx - ax, vy - ay);
        i4 = addVertex(vx + vmx, vy + vmy);
        i5 = _jointIndex1 = addVertex(vx + bx, vy + by);
        _jointIndex2 = addVertex(vx - bx, vy - by);
        addIndices(i1, i3, i4);
      }

      addIndices(i1, i2, i4);
      addIndices(i3, i4, i5);
    } else if (jointStyle == JointStyle.BEVEL) {
      if (isOverlap == false && it >= 0.0) {
        i3 = _jointIndex1 = addVertex(vx + vmx, vy + vmy);
        i4 = addVertex(vx - ax, vy - ay);
        i5 = _jointIndex2 = addVertex(vx - bx, vy - by);
      } else if (isOverlap == false) {
        i3 = _jointIndex2 = addVertex(vx - vmx, vy - vmy);
        i4 = addVertex(vx + ax, vy + ay);
        i5 = _jointIndex1 = addVertex(vx + bx, vy + by);
      } else if (it >= 0.0) {
        i3 = addVertex(vx + ax, vy + ay);
        i4 = addVertex(vx - ax, vy - ay);
        i5 = _jointIndex2 = addVertex(vx - bx, vy - by);
        _jointIndex1 = addVertex(vx + bx, vy + by);
      } else {
        i3 = addVertex(vx - ax, vy - ay);
        i4 = addVertex(vx + ax, vy + ay);
        i5 = _jointIndex1 = addVertex(vx + bx, vy + by);
        _jointIndex2 = addVertex(vx - bx, vy - by);
      }

      addIndices(i1, i2, i3);
      addIndices(i2, i3, i4);
      addIndices(i3, i4, i5);
    } else if (jointStyle == JointStyle.ROUND) {
      if (isOverlap == false && it >= 0.0) {
        i3 = _jointIndex1 = addVertex(vx + vmx, vy + vmy);
        i4 = addVertex(vx - ax, vy - ay);
        _jointIndex2 = _addArc(vx, vy, -ax, -ay, -bx, -by, i3, i4, false);
      } else if (isOverlap == false) {
        i3 = _jointIndex2 = addVertex(vx - vmx, vy - vmy);
        i4 = addVertex(vx + ax, vy + ay);
        _jointIndex1 = _addArc(vx, vy, ax, ay, bx, by, i3, i4, true);
      } else if (it >= 0.0) {
        i3 = addVertex(vx + ax, vy + ay);
        i4 = addVertex(vx - ax, vy - ay);
        _jointIndex1 = addVertex(vx + bx, vy + by);
        _jointIndex2 = _addArc(vx, vy, -ax, -ay, -bx, -by, i3, i4, false);
      } else {
        i3 = addVertex(vx - ax, vy - ay);
        i4 = addVertex(vx + ax, vy + ay);
        _jointIndex2 = addVertex(vx - bx, vy - by);
        _jointIndex1 = _addArc(vx, vy, ax, ay, bx, by, i3, i4, true);
      }

      addIndices(i1, i2, i3);
      addIndices(i2, i3, i4);
    }

    if (isCloseJoint) {
      final x1 = _vertexBuffer[_jointIndex1 * 2 + 0];
      final y1 = _vertexBuffer[_jointIndex1 * 2 + 1];
      final x2 = _vertexBuffer[_jointIndex2 * 2 + 0];
      final y2 = _vertexBuffer[_jointIndex2 * 2 + 1];
      _vertexCount = 0;
      _indexCount = 0;
      _jointIndex1 = addVertex(x1, y1);
      _jointIndex2 = addVertex(x2, y2);
    }
  }

  //---------------------------------------------------------------------------

  int _addArc(num vx, num vy, num n1x, num n1y, num n2x, num n2y, int index1,
      int index2, bool antiClockwise) {
    const tau = 2.0 * pi;
    final startAngle = atan2(n1y, n1x);
    final endAngle = atan2(n2y, n2x);
    final start = startAngle % tau;
    var delta = (endAngle % tau) - start;

    if (antiClockwise && endAngle > startAngle) {
      if (delta >= 0.0) delta -= tau;
    } else if (antiClockwise) {
      delta = (delta % tau) - tau;
    } else if (endAngle < startAngle) {
      if (delta <= 0.0) delta += tau;
    } else {
      delta %= tau;
    }

    final steps = (10 * delta / pi).abs().ceil();
    var index3 = index2;

    final cosR = cos(delta / steps);
    final sinR = sin(delta / steps);
    final tx = vx - vx * cosR + vy * sinR;
    final ty = vy - vx * sinR - vy * cosR;
    var ax = vx + n1x;
    var ay = vy + n1y;

    for (var s = 0; s < steps; s++) {
      final bx = ax * cosR - ay * sinR + tx;
      final by = ax * sinR + ay * cosR + ty;
      final index = addVertex(ax = bx, ay = by);
      addIndices(index1, index3, index);
      index3 = index;
    }

    return index3;
  }
}
