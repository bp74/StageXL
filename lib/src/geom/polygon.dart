part of stagexl;

// PolyK library
// url: http://polyk.ivank.net
// Released under MIT licence.
//
// Copyright (c) 2012 Ivan Kuckir
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

class Polygon {

  final List<Point> points;

  Polygon(List<Point> points) : points = points.toList(growable: false) {

    if (this.points.length < 3) {
      throw new ArgumentError("Please provide three or more points.");
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool IsSimple() {

    Point a1, a2, b1, b2;
    var c = new Point.zero();

    var length = points.length;
    if (length <= 3) return true;

    for(var i = 0; i < length; i++) {

      a1 = points[i];
      a2 = points[(i == length - 1) ? 0 : i];

      for(var j = 0; j < length; j++) {

        if ((i - j).abs() < 2) continue;
        if (j == length - 1 && i == 0) continue;
        if (i == length - 1 && j == 0) continue;

        b1 = points[j];
        b2 = points[(j == length - 1) ? 0 : j];

        if(_getLineIntersection(a1, a2, b1, b2) != null) return false;
      }
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  bool isConvex()  {

    var length = points.length;
    if (length <= 3) return true;

    for(var i = 0; i < points.length; i++) {
      var p1 = points[(i + 0) % points.length];
      var p2 = points[(i + 1) % points.length];
      var p3 = points[(i + 2) % points.length];
      if(!_convex(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)) return false;
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  Rectangle getBounds() {

    var maxX = double.NEGATIVE_INFINITY;
    var minX = double.INFINITY;
    var maxY = double.NEGATIVE_INFINITY;
    var minY = double.INFINITY;

    for(int i = 0; i < points.length; i++) {
      var point = points[i];
      maxX = max(maxX, point.x);
      minX = min(minX, point.x);
      maxY = max(maxY, point.y);
      minY = min(minY, point.y);
    }

    return new Rectangle(minX, minY, maxX - minX, maxY - minY);
  }

  //-----------------------------------------------------------------------------------------------

  List<int> triangulate() {

    var i = 0;
    var al = points.length;
    var result = new List<int>();
    var available = new List<int>.generate(points.length, (i) => i);

    while(al > 3) {

      var i0 = available[(i + 0) % al];
      var i1 = available[(i + 1) % al];
      var i2 = available[(i + 2) % al];

      var ax = points[i0].x, ay = points[i0].y;
      var bx = points[i1].x, by = points[i1].y;
      var cx = points[i2].x, cy = points[i2].y;

      var earFound = false;

      if(_convex(ax, ay, bx, by, cx, cy)) {
        earFound = true;
        for(var j=0; j < al; j++) {
          var vi = available[j];
          if(vi == i0 || vi == i1 || vi == i2) continue;
          if(_pointInTriangle(points[vi].x, points[vi].y, ax, ay, bx, by, cx, cy)) {
            earFound = false;
            break;
          }
        }
      }

      if(earFound) {
        result.addAll([i0, i1, i2]);
        available.removeAt((i + 1) % al);
        al--;
        i = 0;
      } else if(i++ > 3 * al) {
        break; // no convex angles :(
      }
    }

    result.addAll([available[0], available[1], available[2]]);

    return result;
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {

    var ax = 0;
    var ay = 0;
    var bx = points.last.x - px;
    var by = points.last.y - py;
    var depth = 0;

    for(var i = 0; i < points.length; i++) {

      ax = bx;
      ay = by;
      bx = points[i].x - px;
      by = points[i].y - py;

      if(ay < 0 && by < 0) continue;  // both "up" or both "down"
      if(ay > 0 && by > 0) continue;  // both "up" or both "down"
      if(ax < 0 && bx < 0) continue;  // both points on left

      var lx = ax - ay * (bx - ax) / (by - ay);

      if(lx == 0) return true;        // point on edge
      if(lx > 0) depth++;
    }

    return (depth & 1) == 1;
  }

  //-----------------------------------------------------------------------------------------------

  bool _inRect(Point point, Point a1, Point a2) {

    if  (a1.x == a2.x) return point.y >= min(a1.y, a2.y) && point.y <= max(a1.y, a2.y);
    if  (a1.y == a2.y) return point.x >= min(a1.x, a2.x) && point.x <= max(a1.x, a2.x);

    return
        point.x >= min(a1.x, a2.x) && point.x <= max(a1.x, a2.x) &&
        point.y >= min(a1.y, a2.y) && point.y <= max(a1.y, a2.y);
  }

  //-----------------------------------------------------------------------------------------------

  Point _getLineIntersection(Point a1, Point a2, Point b1, Point b2) {

    var dax = (a1.x - a2.x);
    var dbx = (b1.x - b2.x);
    var day = (a1.y - a2.y);
    var dby = (b1.y - b2.y);

    var den = dax * dby - day * dbx;
    if (den == 0) return null;  // parallel

    var a = (a1.x * a2.y - a1.y * a2.x);
    var b = (b1.x * b2.y - b1.y * b2.x);

    var x = (a * dbx - dax * b ) / den;
    var y = (a * dby - day * b ) / den;
    var point = new Point(x, y);

    return _inRect(point, a1, a2) && _inRect(point, b1, b2) ? point : null;
  }

  //-----------------------------------------------------------------------------------------------

  bool _convex(num ax, num ay, num bx, num by, num cx, num cy) {

    return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
  }

  //-----------------------------------------------------------------------------------------------

  bool _pointInTriangle (num px, num py, num ax, num ay, num bx, num by, num cx, num cy) {

    var v0x = cx - ax;
    var v0y = cy - ay;
    var v1x = bx - ax;
    var v1y = by - ay;
    var v2x = px - ax;
    var v2y = py - ay;

    var dot00 = v0x * v0x + v0y * v0y;
    var dot01 = v0x * v1x + v0y * v1y;
    var dot02 = v0x * v2x + v0y * v2y;
    var dot11 = v1x * v1x + v1y * v1y;
    var dot12 = v1x * v2x + v1y * v2y;

    var invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    var u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    var v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return (u >= 0) && (v >= 0) && (u + v < 1);
  }

}