part of stagexl.drawing;

enum PathEncoding { SVG, EaselJS }

abstract class GraphicsCommandDecode extends GraphicsCommand {

  String _path = "";
  final List<GraphicsCommand> _commands = new List<GraphicsCommand>();

  String get path => _path;

  set path(String value) {
    _path = value ?? "";
    _commands.clear();
    _decodePath();
    _invalidate();
  }

  @override
  void updateContext(GraphicsContext context) {
    for (int i = 0; i < _commands.length; i++) {
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

    var paramCounts = [2, 2, 4, 6, 0];
    var p = new Float32List(8);
    var path = this.path;
    var x = 0.0;
    var y = 0.0;
    var w = 0.0;

    for (int i = 0; i < path.length; ) {

      var n = _base64(path.codeUnitAt(i++));
      var m = (n >> 3);
      var l = (n >> 2 & 1) + 2;
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
        _add(new GraphicsCommandMoveTo(x, y));
      } else if (m == 1) {
        _add(new GraphicsCommandLineTo(x, y));
      } else if (m == 2) {
        _add(new GraphicsCommandQuadraticCurveTo(p[0], p[1], x, y));
      } else if (m == 3) {
        _add(new GraphicsCommandBezierCurveTo(p[0], p[1], p[2], p[3], x, y));
      } else if (m == 4) {
        _add(new GraphicsCommandClosePath());
      }
    }
  }
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class GraphicsCommandDecodeSVG extends GraphicsCommandDecode {

  static final RegExp _commandRegExp = new RegExp(r"([a-zA-Z])([^a-zA-Z]+|$)");
  static final RegExp _parameterRegExp = new RegExp(r"\-?\d+(\.\d+)?");
  static final RegExp _lineBreakRegExp = new RegExp(r"\r\n|\r|\n");

  // https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Paths
  // https://svgwg.org/svg2-draft/paths.html

  GraphicsCommandDecodeSVG(String path) {
    this.path = path;
  }

  @override
  void _decodePath() {

    double cx = 0.0;
    double cy = 0.0;
    double startPointX = 0.0;
    double startPointY = 0.0;
    bool startPointValid = false;
    String path = this.path.replaceAll(_lineBreakRegExp, " ");
    List<double> p = new List<double>();

    for (var commandMatch in _commandRegExp.allMatches(path)) {

      var command = commandMatch.group(1);
      var parameter = commandMatch.group(2);

      p.clear();
      for (var parameterMatch in _parameterRegExp.allMatches(parameter)) {
        p.add(double.parse(parameterMatch.group(0)).toDouble());
      }

      switch (command) {

        case "l": // l dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            _add(new GraphicsCommandLineTo(cx += p[i + 0], cy += p[i + 1]));
          }
          break;

        case "L": // L x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            _add(new GraphicsCommandLineTo(cx = p[i + 0], cy = p[i + 1]));
          }
          break;

        case 'm': // m dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            _add(new GraphicsCommandMoveTo(cx += p[i + 0], cy += p[i + 1]));
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'M': // M x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            _add(new GraphicsCommandMoveTo(cx = p[i + 0], cy = p[i + 1]));
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'h': // h dx
          for (int i = 0; i <= p.length - 1; i += 1) {
            _add(new GraphicsCommandLineTo(cx += p[i], cy));
          }
          break;

        case 'H': // H x
          for (int i = 0; i <= p.length - 1; i += 1) {
            _add(new GraphicsCommandLineTo(cx = p[i], cy));
          }
          break;

        case 'v': // v dy
          for (int i = 0; i <= p.length - 1; i += 1) {
            _add(new GraphicsCommandLineTo(cx, cy += p[i]));
          }
          break;

        case 'V': // V y
          for (int i = 0; i <= p.length - 1; i += 1) {
            _add(new GraphicsCommandLineTo(cx, cy = p[i]));
          }
          break;

        case 'c': // c dx1 dy1, dx2 dy2, dx dy
          for (int i = 0; i <= p.length - 6; i += 6) {
            var x1 = cx + p[i + 0];
            var y1 = cy + p[i + 1];
            var x2 = cx + p[i + 2];
            var y2 = cy + p[i + 3];
            var ex = cx += p[i + 4];
            var ey = cy += p[i + 5];
            _add(new GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'C': // C x1 y1, x2 y2, x y
          for (int i = 0; i <= p.length - 6; i += 6) {
            var x1 = p[i + 0];
            var y1 = p[i + 1];
            var x2 = p[i + 2];
            var y2 = p[i + 3];
            var ex = cx = p[i + 4];
            var ey = cy = p[i + 5];
            _add(new GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 's': // s dx2 dy2, dx dy
          for (int i = 0; i <= p.length - 4; i += 4) {
            var l = _commands.isNotEmpty ? _commands.last : null;
            var lx = l is GraphicsCommandBezierCurveTo ? cx - l.controlX2 : 0.0;
            var ly = l is GraphicsCommandBezierCurveTo ? cy - l.controlY2 : 0.0;
            var x1 = cx + lx;
            var y1 = cy + ly;
            var x2 = cx + p[i + 0];
            var y2 = cy + p[i + 1];
            var ex = cx += p[i + 2];
            var ey = cy += p[i + 3];
            _add(new GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'S': // S x2 y2, x y
          for (int i = 0; i <= p.length - 4; i += 4) {
            var l = _commands.isNotEmpty ? _commands.last : null;
            var lx = l is GraphicsCommandBezierCurveTo ? cx - l.controlX2 : 0.0;
            var ly = l is GraphicsCommandBezierCurveTo ? cy - l.controlY2 : 0.0;
            var x1 = cx + lx;
            var y1 = cy + ly;
            var x2 = p[i + 0];
            var y2 = p[i + 1];
            var ex = cx = p[i + 2];
            var ey = cy = p[i + 3];
            _add(new GraphicsCommandBezierCurveTo(x1, y1, x2, y2, ex, ey));
          }
          break;

        case 'q': // q dx1 dy1, dx dy
          for (int i = 0; i <= p.length - 4; i += 4) {
            var x1 = cx + p[i + 0];
            var y1 = cy + p[i + 1];
            var ex = cx += p[i + 2];
            var ey = cy += p[i + 3];
            _add(new GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'Q': // Q x1 y1, x y
          for (int i = 0; i <= p.length - 4; i += 4) {
            var x1 = p[i + 0];
            var y1 = p[i + 1];
            var ex = cx = p[i + 2];
            var ey = cy = p[i + 3];
            _add(new GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 't': // t dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            var l = _commands.isNotEmpty ? _commands.last : null;
            var lx = l is GraphicsCommandQuadraticCurveTo ? cx - l.controlX : 0.0;
            var ly = l is GraphicsCommandQuadraticCurveTo ? cy - l.controlY : 0.0;
            var x1 = cx + lx;
            var y1 = cy + ly;
            var ex = cx += p[i + 2];
            var ey = cy += p[i + 3];
            _add(new GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'T': // T x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            var l = _commands.isNotEmpty ? _commands.last : null;
            var lx = l is GraphicsCommandQuadraticCurveTo ? cx - l.controlX : 0.0;
            var ly = l is GraphicsCommandQuadraticCurveTo ? cy - l.controlY : 0.0;
            var x1 = cx + lx;
            var y1 = cy + ly;
            var ex = cx = p[i + 2];
            var ey = cy = p[i + 3];
            _add(new GraphicsCommandQuadraticCurveTo(x1, y1, ex, ey));
          }
          break;

        case 'a': // a rx ry x-axis-rotation large-arc-flag sweep-flag dx dy
          for (int i = 0; i <= p.length - 7; i += 7) {
            var sx = cx;
            var sy = cy;
            var rx = p[i + 0];
            var ry = p[i + 1];
            var ra = p[i + 2] * PI / 180.0;
            var fa = p[i + 3] != 0.0;
            var fs = p[i + 4] != 0.0;
            var ex = cx += p[i + 5];
            var ey = cy += p[i + 6];
            _arcElliptical(sx, sy, rx, ry, ra, fa, fs, ex, ey);
          }
          break;

        case 'A': // A rx ry x-axis-rotation large-arc-flag sweep-flag x y
          for (int i = 0; i <= p.length - 7; i += 7) {
            var sx = cx;
            var sy = cy;
            var rx = p[i + 0];
            var ry = p[i + 1];
            var ra = p[i + 2] * PI / 180.0;
            var fa = p[i + 3] != 0.0;
            var fs = p[i + 4] != 0.0;
            var ex = cx = p[i + 5];
            var ey = cy = p[i + 6];
            _arcElliptical(sx, sy, rx, ry, ra, fa, fs, ex, ey);
          }
          break;

        case 'z': // z
        case 'Z': // Z
          cx = startPointValid ? startPointX : 0.0;
          cy = startPointValid ? startPointY : 0.0;
          startPointValid = false;
          _add(new GraphicsCommandClosePath());
          _add(new GraphicsCommandMoveTo(cx, cy));
          break;
      }
    }
  }

  void _arcElliptical(
      double startX, double startY, double radiusX, double radiusY,
      double rotation, bool largeArcFlag, bool sweepFlag,
      double endX, double endY) {

    if (radiusX == 0.0 || radiusY == 0.0) {

      _add(new GraphicsCommandLineTo(endX, endY));

    } else {

      var cosRotation = cos(rotation);
      var sinRotation = sin(rotation);
      var rx = radiusX.abs();
      var ry = radiusY.abs();
      var mx = (startX + endX) / 2.0;
      var my = (startY + endY) / 2.0;
      var sx = (startX - endX) / 2.0;
      var sy = (startY - endY) / 2.0;
      var ux = cosRotation * sx + sinRotation * sy;
      var uy = cosRotation * sy - sinRotation * sx;

      var l = sqrt(pow(ux / rx, 2) + pow(uy / ry, 2));
      if (l > 1.0) { rx = rx * l; ry = ry * l; }

      var b = pow(uy * rx, 2) + pow(ux * ry, 2);
      if (b > -0.00001 && b < 0.00001) b = 0.0;

      var t = pow(rx * ry, 2) - b;
      if (t > -0.00001 && t < 0.00001) t = 0.0;

      var factor = sqrt(t / b);
      if (largeArcFlag == sweepFlag) factor = 0.0 - factor;

      var vx = factor * uy * rx / ry;
      var vy = factor * ux * ry / rx;
      var cx = mx + cosRotation * vx + sinRotation * vy;
      var cy = my + sinRotation * vx - cosRotation * vy;
      var a1 = atan2((uy + vy) * rx, (ux - vx) * ry);
      var a2 = atan2((vy - uy) * rx, (-ux - vx) * ry);
      var antiClockwise = sweepFlag ? false : true;

      _add(new GraphicsCommandArcElliptical(
          cx, cy, rx, ry, rotation, a1, a2, antiClockwise));
    }
  }
}
