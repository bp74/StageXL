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

  bool isSimple() {

    int length = points.length;
    if (length <= 3) return true;

    for(int i = 0; i < length; i++) {

      Point a1 = points[i];
      Point a2 = points[(i == length - 1) ? 0 : i];

      for(int j = 0; j < length; j++) {

        if ((i - j).abs() < 2) continue;
        if (j == length - 1 && i == 0) continue;
        if (i == length - 1 && j == 0) continue;

        Point b1 = points[j];
        Point b2 = points[(j == length - 1) ? 0 : j];

        if(_getLineIntersection(a1, a2, b1, b2) != null) return false;
      }
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  bool isConvex()  {

    int length = points.length;
    if (length <= 3) return true;

    for(int i = 0; i < length; i++) {
      Point p1 = points[(i + 0) % length];
      Point p2 = points[(i + 1) % length];
      Point p3 = points[(i + 2) % length];
      if(!_convex(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)) return false;
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  Rectangle getBounds() {

    num maxX = double.NEGATIVE_INFINITY;
    num minX = double.INFINITY;
    num maxY = double.NEGATIVE_INFINITY;
    num minY = double.INFINITY;

    for(int i = 0; i < points.length; i++) {
      Point point = points[i];
      maxX = max(maxX, point.x);
      minX = min(minX, point.x);
      maxY = max(maxY, point.y);
      minY = min(minY, point.y);
    }

    return new Rectangle(minX, minY, maxX - minX, maxY - minY);
  }

  //-----------------------------------------------------------------------------------------------

  List<int> triangulate() {

    int i = 0;
    int al = points.length;
    List<int> result = new List<int>();
    List<int> available = new List<int>();

    for(int p = 0; p < points.length; p++) {
      available.add(p);
    }

    while(al > 3) {

      int i0 = available[(i + 0) % al];
      int i1 = available[(i + 1) % al];
      int i2 = available[(i + 2) % al];

      num ax = points[i0].x;
      num ay = points[i0].y;
      num bx = points[i1].x;
      num by = points[i1].y;
      num cx = points[i2].x;
      num cy = points[i2].y;

      bool earFound = false;

      if(_convex(ax, ay, bx, by, cx, cy)) {
        earFound = true;

        for(int j = 0; j < al; j++) {
          int vi = available[j];
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

    num ax = 0;
    num ay = 0;
    num bx = points[points.length - 1].x - px;
    num by = points[points.length - 1].y - py;
    int depth = 0;

    for(int i = 0; i < points.length; i++) {

      ax = bx;
      ay = by;
      bx = points[i].x - px;
      by = points[i].y - py;

      if (ay < 0 && by < 0) continue;  // both "up" or both "down"
      if (ay > 0 && by > 0) continue;  // both "up" or both "down"
      if (ax < 0 && bx < 0) continue;  // both points on left

      num lx = ax - ay * (bx - ax) / (by - ay);

      if (lx == 0) return true;        // point on edge
      if (lx > 0) depth++;
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

    num dax = (a1.x - a2.x);
    num dbx = (b1.x - b2.x);
    num day = (a1.y - a2.y);
    num dby = (b1.y - b2.y);

    num den = dax * dby - day * dbx;
    if (den == 0) return null;  // parallel

    num a = (a1.x * a2.y - a1.y * a2.x);
    num b = (b1.x * b2.y - b1.y * b2.x);

    num x = (a * dbx - dax * b ) / den;
    num y = (a * dby - day * b ) / den;
    Point point = new Point(x, y);

    return _inRect(point, a1, a2) && _inRect(point, b1, b2) ? point : null;
  }

  //-----------------------------------------------------------------------------------------------

  bool _convex(num ax, num ay, num bx, num by, num cx, num cy) {

    return (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;
  }

  //-----------------------------------------------------------------------------------------------

  bool _pointInTriangle (num px, num py, num ax, num ay, num bx, num by, num cx, num cy) {

    num v0x = cx - ax;
    num v0y = cy - ay;
    num v1x = bx - ax;
    num v1y = by - ay;
    num v2x = px - ax;
    num v2y = py - ay;

    num dot00 = v0x * v0x + v0y * v0y;
    num dot01 = v0x * v1x + v0y * v1y;
    num dot02 = v0x * v2x + v0y * v2y;
    num dot11 = v1x * v1x + v1y * v1y;
    num dot12 = v1x * v2x + v1y * v2y;

    num invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    num u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    num v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return (u >= 0) && (v >= 0) && (u + v < 1);
  }

}