part of stagexl.drawing;

class _GraphicsCommandDecodeCommand {
  final String method;
  final Float32List parameters;
  _GraphicsCommandDecodeCommand(this.method, this.parameters);
}

enum PathEncoding { SVG, EaselJS }

//------------------------------------------------------------------------------

abstract class GraphicsCommandDecode extends GraphicsCommand {

  String _path = "";
  final List<_GraphicsCommandDecodeCommand> _commands = new List<_GraphicsCommandDecodeCommand>();

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
      var command = _commands[i];
      var p = command.parameters;
      switch (command.method) {
        case "mt": context.moveTo(p[0], p[1]); break;
        case "lt": context.lineTo(p[0], p[1]); break;
        case "qc": context.quadraticCurveTo(p[0], p[1], p[2], p[3]); break;
        case "bc": context.bezierCurveTo(p[0], p[1], p[2], p[3], p[4], p[5]); break;
        case "ac": context.arc(p[0], p[1], p[2], p[3], p[4], p[5] != 0.0); break;
        case "ae": context.arcElliptical(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7] != 0.0); break;
        case "cp": context.closePath(); break;
      }
    }
  }

  void _addCommand(String method, List<double> parameters) {
    var p = new Float32List.fromList(parameters);
    _commands.add(new _GraphicsCommandDecodeCommand(method, p));
  }

  void _decodePath();
}

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

class GraphicsCommandDecodeEaselJS extends GraphicsCommandDecode {

  static const Map<String, int> _BASE_64 = const <String, int>{
    "A": 0,"B": 1,"C": 2,"D": 3,"E": 4,"F": 5,"G": 6,"H": 7,
    "I": 8,"J": 9,"K":10,"L":11,"M":12,"N":13,"O":14,"P":15,
    "Q":16,"R":17,"S":18,"T":19,"U":20,"V":21,"W":22,"X":23,
    "Y":24,"Z":25,"a":26,"b":27,"c":28,"d":29,"e":30,"f":31,
    "g":32,"h":33,"i":34,"j":35,"k":36,"l":37,"m":38,"n":39,
    "o":40,"p":41,"q":42,"r":43,"s":44,"t":45,"u":46,"v":47,
    "w":48,"x":49,"y":50,"z":51,"0":52,"1":53,"2":54,"3":55,
    "4":56,"5":57,"6":58,"7":59,"8":60,"9":61,"+":62,"/":63};

  GraphicsCommandDecodeEaselJS(String path) {
    this.path = path;
  }

  @override
  void _decodePath() {

    var methodNames = ["mt", "lt", "qc", "bc", "cp"];
    var paramCounts = [2, 2, 4, 6, 0];
    var path = this.path;
    var x = 0.0;
    var y = 0.0;

    for (int i = 0; i < path.length; ) {

      var n = _BASE_64[path[i]];
      var m = (n >> 3);
      var l = (n >> 2 & 1) + 2;

      var f = methodNames[m];
      var c = paramCounts[m];
      var p = new Float32List(c);
      i++;

      if (m == 0) x = y = 0.0;

      for (var j = 0; j < c; j++) {
        var v = _BASE_64[path[i]];
        var s = (v >> 5) > 0 ? -1.0 : 1.0;
        v = ((v & 31) << 6) | (_BASE_64[path[i + 1]]);
        if (l == 3) v = (v << 6) | (_BASE_64[path[i + 2]]);
        var w = s * v / 10.0;
        if (j % 2 > 0) x = (w += x); else y = (w += y);
        p[j] = w.toDouble();
        i += l;
      }

      _addCommand(f, p);
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

    var cx = 0.0;
    var cy = 0.0;
    var startPointX = 0.0;
    var startPointY = 0.0;
    var startPointValid = false;
    var path = this.path.replaceAll(_lineBreakRegExp, " ");

    for (var commandMatch in _commandRegExp.allMatches(path)) {

      var command = commandMatch.group(1);
      var parameter = commandMatch.group(2);

      var p = _parameterRegExp.allMatches(parameter)
          .map((m) => double.parse(m.group(0)))
          .toList();

      switch (command) {

        case "l": // l dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            _addCommand("lt", [cx += p[i + 0], cy += p[i + 1]]);
          }
          break;

        case "L": // L x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            _addCommand("lt", [cx = p[i + 0], cy = p[i + 1]]);
          }
          break;

        case 'm': // m dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            _addCommand("mt", [cx += p[i + 0], cy += p[i + 1]]);
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'M': // M x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            _addCommand("mt", [cx = p[i + 0], cy = p[i + 1]]);
            startPointX = startPointValid ? startPointX : cx;
            startPointY = startPointValid ? startPointY : cy;
            startPointValid = true;
          }
          break;

        case 'h': // h dx
          for (int i = 0; i <= p.length - 1; i += 1) {
            _addCommand("lt", [cx += p[i + 0], cy]);
          }
          break;

        case 'H': // H x
          for (int i = 0; i <= p.length - 1; i += 1) {
            _addCommand("lt", [cx = p[i + 0], cy]);
          }
          break;

        case 'v': // v dy
          for (int i = 0; i <= p.length - 1; i += 1) {
            _addCommand("lt", [cx, cy += p[i + 0]]);
          }
          break;

        case 'V': // V y
          for (int i = 0; i <= p.length - 1; i += 1) {
            _addCommand("lt", [cx, cy = p[i + 0]]);
          }
          break;

        case 'c': // c dx1 dy1, dx2 dy2, dx dy
          for (int i = 0; i <= p.length - 6; i += 6) {
            var x1 = cx + p[i + 0];
            var y1 = cy + p[i + 1];
            var x2 = cx + p[i + 2];
            var y2 = cy + p[i + 3];
            _addCommand("bc", [x1, y1, x2, y2, cx += p[i + 4], cy += p[i + 5]]);
          }
          break;

        case 'C': // C x1 y1, x2 y2, x y
          for (int i = 0; i <= p.length - 6; i += 6) {
            var x1 = p[i + 0];
            var y1 = p[i + 1];
            var x2 = p[i + 2];
            var y2 = p[i + 3];
            _addCommand("bc", [x1, y1, x2, y2, cx = p[i + 4], cy = p[i + 5]]);
          }
          break;

        case 's': // s dx2 dy2, dx dy
          for (int i = 0; i <= p.length - 4; i += 4) {
            var last = _commands.isNotEmpty ? _commands.last : null;
            var isbc = last != null && last.method == 'bc';
            var x1 = cx + (isbc ? (cx - last.parameters[2]) : 0.0);
            var y1 = cy + (isbc ? (cy - last.parameters[3]) : 0.0);
            var x2 = p[i + 0];
            var y2 = p[i + 1];
            _addCommand("bc",[x1, y1, x2, y2, cx += p[i + 2], cy += p[i + 3]]);
          }
          break;

        case 'S': // S x2 y2, x y
          for (int i = 0; i <= p.length - 4; i += 4) {
            var last = _commands.isNotEmpty ? _commands.last : null;
            var isbc = last != null && last.method == 'bc';
            var x1 = cx + (isbc ? (cx - last.parameters[2]) : 0.0);
            var y1 = cy + (isbc ? (cy - last.parameters[3]) : 0.0);
            var x2 = p[i + 0];
            var y2 = p[i + 1];
            _addCommand("bc", [x1, y1, x2, y2, cx = p[i + 2], cy = p[i + 3]]);
          }
          break;

        case 'q': // q dx1 dy1, dx dy
          for (int i = 0; i <= p.length - 4; i += 4) {
            var x1 = cx + p[i + 0];
            var y1 = cy + p[i + 1];
            _addCommand("qc", [x1, y1, cx += p[i + 2], cy += p[i + 3]]);
          }
          break;

        case 'Q': // Q x1 y1, x y
          for (int i = 0; i <= p.length - 4; i += 4) {
            var x1 = p[i + 0];
            var y1 = p[i + 1];
            _addCommand("qc", [x1, y1, cx = p[i + 2], cy = p[i + 3]]);
          }
          break;

        case 't': // t dx dy
          for (int i = 0; i <= p.length - 2; i += 2) {
            var last = _commands.isNotEmpty ? _commands.last : null;
            var isqc = last != null && last.method == 'qc';
            var x1 = cx + (isqc ? (cx - last.parameters[0]) : 0.0);
            var y1 = cy + (isqc ? (cy - last.parameters[1]) : 0.0);
            _addCommand("qc", [x1, y1, cx += p[i + 0], cy += p[i + 1]]);
          }
          break;

        case 'T': // T x y
          for (int i = 0; i <= p.length - 2; i += 2) {
            var last = _commands.isNotEmpty ? _commands.last : null;
            var isqc = last != null && last.method == 'qc';
            var x1 = cx + (isqc ? (cx - last.parameters[0]) : 0.0);
            var y1 = cy + (isqc ? (cy - last.parameters[1]) : 0.0);
            _addCommand("qc", [x1, y1, cx = p[i + 0], cy = p[i + 1]]);
          }
          break;

        case 'a': // a rx ry x-axis-rotation large-arc-flag sweep-flag dx dy
          for (int i = 0; i <= p.length - 7; i += 7) {
            var rx = p[i + 0];
            var ry = p[i + 1];
            var ra = p[i + 2] * PI / 180.0;
            var fa = p[i + 3] != 0.0;
            var fs = p[i + 4] != 0.0;
            _arcElliptical(cx, cy, rx, ry, ra, fa, fs, cx += p[i + 5], cy += p[i + 6]);
          }
          break;

        case 'A': // A rx ry x-axis-rotation large-arc-flag sweep-flag x y
          for (int i = 0; i <= p.length - 7; i += 7) {
            var rx = p[i + 0];
            var ry = p[i + 1];
            var ra = p[i + 2] * PI / 180.0;
            var fa = p[i + 3] != 0.0;
            var fs = p[i + 4] != 0.0;
            _arcElliptical(cx, cy, rx, ry, ra, fa, fs, cx = p[i + 5], cy = p[i + 6]);
          }
          break;

        case 'z': // z
        case 'Z': // Z
          cx = startPointValid ? startPointX : 0.0;
          cy = startPointValid ? startPointY : 0.0;
          startPointValid = false;
          _addCommand("cp", []);
          _addCommand("mt", [cx, cy]);
          break;
      }
    }
  }

  void _arcElliptical(
      double startX, double startY, double radiusX, double radiusY,
      double rotation, bool largeArcFlag, bool sweepFlag,
      double endX, double endY) {

    if (radiusX == 0.0 || radiusY == 0.0) {

      _addCommand("lt", [endX, endY]);

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

      var lambda = sqrt((ux * ux) / (rx * rx) + (uy * uy) / (ry * ry));
      if (lambda > 1.0) { rx *= lambda; ry *= lambda; }

      var b = rx * rx * uy * uy + ry * ry * ux * ux;
      if (b > -0.00001 && b < 0.00001) b = 0.0;

      var t = rx * rx * ry * ry - b;
      if (t > -0.00001 && t < 0.00001) t = 0.0;

      var factor = sqrt(t / b);
      if (largeArcFlag == sweepFlag) factor = 0.0 - factor;

      var vx = factor * uy * rx / ry;
      var vy = factor * ux * ry / rx;
      var cx = mx + cosRotation * vx + sinRotation * vy;
      var cy = my + sinRotation * vx - cosRotation * vy;
      var a1 = atan2((uy + vy) * rx, (ux - vx) * ry);
      var a2 = atan2((vy - uy) * rx, (-ux - vx) * ry);
      var antiClockwise = sweepFlag ? 0.0 : 1.0;

      _addCommand("ae", [cx, cy, rx, ry, rotation, a1, a2, antiClockwise]);
    }
  }
}
