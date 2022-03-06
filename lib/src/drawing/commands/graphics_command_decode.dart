part of stagexl.drawing;

enum PathEncoding { SVG, EaselJS }

abstract class GraphicsCommandDecode extends GraphicsCommand {
  String _path = '';
  final List<GraphicsCommand> _commands = <GraphicsCommand>[];

  String get path => _path;

  set path(String value) {
    _path = value;
    _commands.clear();
    _decodePath();
    _invalidate();
  }

  @override
  void updateContext(GraphicsContext context) {
    for (var i = 0; i < _commands.length; i++) {
      _commands[i].updateContext(context);
    }
  }

  void _add(GraphicsCommand command) {
    _commands.add(command);
  }

  void _decodePath();
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class GraphicsCommandDecodeEaselJS extends GraphicsCommandDecode {
  GraphicsCommandDecodeEaselJS(String path) {
    this.path = path;
  }

  int _base64(int codeUnit) {
    if (codeUnit >= 0x41 && codeUnit <= 0x5A) return codeUnit - 0x41 + 0;
    if (codeUnit >= 0x61 && codeUnit <= 0x7A) return codeUnit - 0x61 + 26;
    if (codeUnit >= 0x30 && codeUnit <= 0x39) return codeUnit - 0x30 + 52;
    if (codeUnit == 0x2B) return 62;
    if (codeUnit == 0x2F) return 63;
    return 0;
  }

  @override
  void _decodePath() {
    final paramCounts = [2, 2, 4, 6, 0];
    final p = Float32List(8);
    final path = this.path;
    var x = 0.0;
    var y = 0.0;
    var w = 0.0;

    for (var i = 0; i < path.length;) {
      var n = _base64(path.codeUnitAt(i++));
      final m = n >> 3;
      final l = (n >> 2 & 1) + 2;
      var v = 0;

      if (m == 0) x = y = 0.0;

      for (var j = 0; j < paramCounts[m]; j++) {
        n = _base64(path.codeUnitAt(i++));
        v = n & 31;
        v = (l >= 2) ? (v << 6) | _base64(path.codeUnitAt(i++)) : v;
        v = (l >= 3) ? (v << 6) | _base64(path.codeUnitAt(i++)) : v;
        w = (n < 32) ? v / 10.0 : 0.0 - v / 10.0;
        x = (j & 1) == 0 ? w += x : x;
        y = (j & 1) == 1 ? w += y : y;
        p[j] = w;
      }

      if (m == 0) {
        _add(GraphicsCommandMoveTo(x, y));
      } else if (m == 1) {
        _add(GraphicsCommandLineTo(x, y));
      } else if (m == 2) {
        _add(GraphicsCommandQuadraticCurveTo(p[0], p[1], x, y));
      } else if (m == 3) {
        _add(GraphicsCommandBezierCurveTo(p[0], p[1], p[2], p[3], x, y));
      } else if (m == 4) {
        _add(GraphicsCommandClosePath());
      }
    }
  }
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class GraphicsCommandDecodeSVG extends GraphicsCommandDecode {
  static final RegExp _commandRegExp = RegExp(r'([a-zA-Z])([^a-zA-Z]+|$)');
  static final RegExp _parameterRegExp = RegExp(r'\-?\d+(\.\d+)?');
  static final RegExp _lineBreakRegExp = RegExp(r'\r\n|\r|\n');

  // https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
  // https://svgwg.org/svg2-draft/paths.html

  GraphicsCommandDecodeSVG(String path) {
    this.path = path;
  }

  @override
  void _decodePath() {
    var cx = 0.0;
    var cy = 0.0;
    var startPointX = 0.0;
    var startPointY = 0.0;
    var startPointValid = false;
    final path = this.path.replaceAll(_lineBreakRegExp, ' ');
    final p = <double>[];

    for (var commandMatch in _commandRegExp.allMatches(path)) {
      final command = commandMatch.group(1);
      final parameter = commandMatch.group(2)!;

      p.clear();
      for (var parameterMatch in _parameterRegExp.allMatches(parameter)) {
        p.add(double.parse(parameterMatch.group(0)!));
      }

      switch (command) {
        case 'l': // l dx dy
          for (var i = 0; i <= p.length - 2; i += 2) {
            _add(GraphicsCommandLineTo(cx += p[i + 0], cy += p[i + 1]));
          }
          break;

        case 'L': // L x y
          for (var i = 0; i <= p.length - 2; i += 2) {
            _add(GraphicsCommandLineTo(cx = p[i + 0], cy = p[i + 1]));
          }
          break;

        case 'm': // m dx dy
          for (var i = 0; i <= p.length - 2; i += 2) {
            _add(GraphicsCommandMoveTo(cx += p[i + 0], cy += p[i + 1]));
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'M': // M x y
          for (var i = 0; i <= p.length - 2; i += 2) {
            _add(GraphicsCommandMoveTo(cx = p[i + 0], cy = p[i + 1]));
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'h': // h dx
          for (var i = 0; i <= p.length - 1; i += 1) {
            _add(GraphicsCommandLineTo(cx += p[i], cy));
          }
          break;

        case 'H': // H x
          for (var i = 0; i <= p.length - 1; i += 1) {
            _add(GraphicsCommandLineTo(cx = p[i], cy));
          }
          break;

        case 'v': // v dy
          for (var i = 0; i <= p.length - 1; i += 1) {
            _add(GraphicsCommandLineTo(cx, cy += p[i]));
          }
          break;

        case 'V': // V y
          for (var i = 0; i <= p.length - 1; i += 1) {
            _add(GraphicsCommandLineTo(cx, cy = p[i]));
          }
          break;

        case 'c': // c dx1 dy1, dx2 dy2, dx dy
          for (var i = 0; i <= p.length - 6; i += 6) {
            final x1 = cx + p[i + 0];
            final y1 = cy + p[i + 1];
            final x2 = cx + p[i + 2];
            final y2 = cy + p[i + 3];
            final ex = cx += p[i + 4];
            final ey = cy += p[i + 5];
            _add(GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'C': // C x1 y1, x2 y2, x y
          for (var i = 0; i <= p.length - 6; i += 6) {
            final x1 = p[i + 0];
            final y1 = p[i + 1];
            final x2 = p[i + 2];
            final y2 = p[i + 3];
            final ex = cx = p[i + 4];
            final ey = cy = p[i + 5];
            _add(GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 's': // s dx2 dy2, dx dy
          for (var i = 0; i <= p.length - 4; i += 4) {
            final l = _commands.isNotEmpty ? _commands.last : null;
            final lx =
                l is GraphicsCommandBezierCurveTo ? cx - l.controlX2 : 0.0;
            final ly =
                l is GraphicsCommandBezierCurveTo ? cy - l.controlY2 : 0.0;
            final x1 = cx + lx;
            final y1 = cy + ly;
            final x2 = cx + p[i + 0];
            final y2 = cy + p[i + 1];
            final ex = cx += p[i + 2];
            final ey = cy += p[i + 3];
            _add(GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'S': // S x2 y2, x y
          for (var i = 0; i <= p.length - 4; i += 4) {
            final l = _commands.isNotEmpty ? _commands.last : null;
            final lx =
                l is GraphicsCommandBezierCurveTo ? cx - l.controlX2 : 0.0;
            final ly =
                l is GraphicsCommandBezierCurveTo ? cy - l.controlY2 : 0.0;
            final x1 = cx + lx;
            final y1 = cy + ly;
            final x2 = p[i + 0];
            final y2 = p[i + 1];
            final ex = cx = p[i + 2];
            final ey = cy = p[i + 3];
            _add(GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'q': // q dx1 dy1, dx dy
          for (var i = 0; i <= p.length - 4; i += 4) {
            final x1 = cx + p[i + 0];
            final y1 = cy + p[i + 1];
            final ex = cx += p[i + 2];
            final ey = cy += p[i + 3];
            _add(GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'Q': // Q x1 y1, x y
          for (var i = 0; i <= p.length - 4; i += 4) {
            final x1 = p[i + 0];
            final y1 = p[i + 1];
            final ex = cx = p[i + 2];
            final ey = cy = p[i + 3];
            _add(GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 't': // t dx dy
          for (var i = 0; i <= p.length - 2; i += 2) {
            final l = _commands.isNotEmpty ? _commands.last : null;
            final lx =
                l is GraphicsCommandQuadraticCurveTo ? cx - l.controlX : 0.0;
            final ly =
                l is GraphicsCommandQuadraticCurveTo ? cy - l.controlY : 0.0;
            final x1 = cx + lx;
            final y1 = cy + ly;
            final ex = cx += p[i + 2];
            final ey = cy += p[i + 3];
            _add(GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'T': // T x y
          for (var i = 0; i <= p.length - 2; i += 2) {
            final l = _commands.isNotEmpty ? _commands.last : null;
            final lx =
                l is GraphicsCommandQuadraticCurveTo ? cx - l.controlX : 0.0;
            final ly =
                l is GraphicsCommandQuadraticCurveTo ? cy - l.controlY : 0.0;
            final x1 = cx + lx;
            final y1 = cy + ly;
            final ex = cx = p[i + 2];
            final ey = cy = p[i + 3];
            _add(GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'a': // a rx ry x-axis-rotation large-arc-flag sweep-flag dx dy
          for (var i = 0; i <= p.length - 7; i += 7) {
            final sx = cx;
            final sy = cy;
            final rx = p[i + 0];
            final ry = p[i + 1];
            final ra = p[i + 2] * pi / 180.0;
            final fa = p[i + 3] != 0.0;
            final fs = p[i + 4] != 0.0;
            final ex = cx += p[i + 5];
            final ey = cy += p[i + 6];
            _arcElliptical(sx, sy, rx, ry, ra, fa, fs, ex, ey);
          }
          break;

        case 'A': // A rx ry x-axis-rotation large-arc-flag sweep-flag x y
          for (var i = 0; i <= p.length - 7; i += 7) {
            final sx = cx;
            final sy = cy;
            final rx = p[i + 0];
            final ry = p[i + 1];
            final ra = p[i + 2] * pi / 180.0;
            final fa = p[i + 3] != 0.0;
            final fs = p[i + 4] != 0.0;
            final ex = cx = p[i + 5];
            final ey = cy = p[i + 6];
            _arcElliptical(sx, sy, rx, ry, ra, fa, fs, ex, ey);
          }
          break;

        case 'z': // z
        case 'Z': // Z
          cx = startPointValid ? startPointX : 0.0;
          cy = startPointValid ? startPointY : 0.0;
          startPointValid = false;
          _add(GraphicsCommandClosePath());
          _add(GraphicsCommandMoveTo(cx, cy));
          break;
      }
    }
  }

  void _arcElliptical(
      double startX,
      double startY,
      double radiusX,
      double radiusY,
      double rotation,
      bool largeArcFlag,
      bool sweepFlag,
      double endX,
      double endY) {
    if (radiusX == 0.0 || radiusY == 0.0) {
      _add(GraphicsCommandLineTo(endX, endY));
    } else {
      final cosRotation = cos(rotation);
      final sinRotation = sin(rotation);
      var rx = radiusX.abs();
      var ry = radiusY.abs();
      final mx = (startX + endX) / 2.0;
      final my = (startY + endY) / 2.0;
      final sx = (startX - endX) / 2.0;
      final sy = (startY - endY) / 2.0;
      final ux = cosRotation * sx + sinRotation * sy;
      final uy = cosRotation * sy - sinRotation * sx;

      final l = sqrt(pow(ux / rx, 2) + pow(uy / ry, 2));
      if (l > 1.0) {
        rx = rx * l;
        ry = ry * l;
      }

      var b = pow(uy * rx, 2) + pow(ux * ry, 2);
      if (b > -0.00001 && b < 0.00001) b = 0.0;

      var t = pow(rx * ry, 2) - b;
      if (t > -0.00001 && t < 0.00001) t = 0.0;

      var factor = sqrt(t / b);
      if (largeArcFlag == sweepFlag) factor = 0.0 - factor;

      final vx = factor * uy * rx / ry;
      final vy = factor * ux * ry / rx;
      final cx = mx + cosRotation * vx + sinRotation * vy;
      final cy = my + sinRotation * vx - cosRotation * vy;
      final a1 = atan2((uy + vy) * rx, (ux - vx) * ry);
      final a2 = atan2((vy - uy) * rx, (-ux - vx) * ry);
      final antiClockwise = !sweepFlag;

      _add(GraphicsCommandArcElliptical(
          cx, cy, rx, ry, rotation, a1, a2, antiClockwise));
    }
  }
}
