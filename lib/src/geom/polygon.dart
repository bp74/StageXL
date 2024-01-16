import 'dart:math' hide Point, Rectangle;

import 'point.dart';
import 'rectangle.dart';

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
  final List<Point<num>> points;

  Polygon(List<Point<num>> points) : points = points.toList(growable: false) {
    if (this.points.length < 3) {
      throw ArgumentError('Please provide three or more points.');
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool isSimple() {
    final length = points.length;
    if (length <= 3) return true;

    for (var i = 0; i < length; i++) {
      final a1 = points[i];
      final a2 = points[i + 1 < length ? i + 1 : 0];

      for (var j = 0; j < length; j++) {
        if ((i - j).abs() < 2) continue;
        if (j == length - 1 && i == 0) continue;
        if (i == length - 1 && j == 0) continue;

        final b1 = points[j];
        final b2 = points[j + 1 < length ? j + 1 : 0];

        if (_getLineIntersection(a1, a2, b1, b2) != null) return false;
      }
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  bool isConvex() {
    final length = points.length;
    if (length <= 3) return true;

    for (var i = 0; i < length; i++) {
      final p1 = points[(i + 0) % length];
      final p2 = points[(i + 1) % length];
      final p3 = points[(i + 2) % length];
      if (!_convex(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)) return false;
    }

    return true;
  }

  //-----------------------------------------------------------------------------------------------

  Rectangle<num> getBounds() {
    num maxX = double.negativeInfinity;
    num minX = double.infinity;
    num maxY = double.negativeInfinity;
    num minY = double.infinity;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      maxX = max(maxX, point.x);
      minX = min(minX, point.x);
      maxY = max(maxY, point.y);
      minY = min(minY, point.y);
    }

    return Rectangle<num>(minX, minY, maxX - minX, maxY - minY);
  }

  //-----------------------------------------------------------------------------------------------

  List<int> triangulate() {
    var i = 0;
    var al = points.length;
    final result = <int>[];
    final available = <int>[];

    for (var p = 0; p < points.length; p++) {
      available.add(p);
    }

    while (al > 3) {
      final i0 = available[(i + 0) % al];
      final i1 = available[(i + 1) % al];
      final i2 = available[(i + 2) % al];

      final ax = points[i0].x;
      final ay = points[i0].y;
      final bx = points[i1].x;
      final by = points[i1].y;
      final cx = points[i2].x;
      final cy = points[i2].y;

      var earFound = false;

      if (_convex(ax, ay, bx, by, cx, cy)) {
        earFound = true;

        for (var j = 0; j < al; j++) {
          final vi = available[j];
          if (vi == i0 || vi == i1 || vi == i2) continue;
          if (_pointInTriangle(
              points[vi].x, points[vi].y, ax, ay, bx, by, cx, cy)) {
            earFound = false;
            break;
          }
        }
      }

      if (earFound) {
        result.add(i0);
        result.add(i1);
        result.add(i2);
        available.removeAt((i + 1) % al);
        al--;
        i = 0;
      } else if (i++ > 3 * al) {
        break; // no convex angles :(
      }
    }

    result.add(available[0]);
    result.add(available[1]);
    result.add(available[2]);

    // http://dartbug.com/10489
    return result.toList(growable: false);
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(num px, num py) {
    num ax = 0;
    num ay = 0;
    var bx = points[points.length - 1].x - px;
    var by = points[points.length - 1].y - py;
    var depth = 0;

    for (var i = 0; i < points.length; i++) {
      ax = bx;
      ay = by;
      bx = points[i].x - px;
      by = points[i].y - py;

      if (ay < 0 && by < 0) continue; // both 'up' or both 'down'
      if (ay > 0 && by > 0) continue; // both 'up' or both 'down'
      if (ax < 0 && bx < 0) continue; // both points on left

      final num lx = ax - ay * (bx - ax) / (by - ay);

      if (lx == 0) return true; // point on edge
      if (lx > 0) depth++;
    }

    return (depth & 1) == 1;
  }

  //-----------------------------------------------------------------------------------------------

  bool _inRect(Point<num> point, Point<num> a1, Point<num> a2) {
    final x = point.x;
    final y = point.y;
    final left = a1.x < a2.x ? a1.x : a2.x;
    final top = a1.y < a2.y ? a1.y : a2.y;
    final right = a1.x > a2.x ? a1.x : a2.x;
    final bottom = a1.y > a2.y ? a1.y : a2.y;

    return x >= left && x <= right && y >= top && y <= bottom;
  }

  //-----------------------------------------------------------------------------------------------

  Point<num>? _getLineIntersection(
      Point<num> a1, Point<num> a2, Point<num> b1, Point<num> b2) {
    final dax = a1.x - a2.x;
    final dbx = b1.x - b2.x;
    final day = a1.y - a2.y;
    final dby = b1.y - b2.y;

    final den = dax * dby - day * dbx;
    if (den == 0) return null; // parallel

    final a = a1.x * a2.y - a1.y * a2.x;
    final b = b1.x * b2.y - b1.y * b2.x;

    final x = (a * dbx - dax * b) / den;
    final y = (a * dby - day * b) / den;
    final point = Point<num>(x, y);

    return _inRect(point, a1, a2) && _inRect(point, b1, b2) ? point : null;
  }

  //-----------------------------------------------------------------------------------------------

  bool _convex(num ax, num ay, num bx, num by, num cx, num cy) =>
      (ay - by) * (cx - bx) + (bx - ax) * (cy - by) >= 0;

  //-----------------------------------------------------------------------------------------------

  bool _pointInTriangle(
      num px, num py, num ax, num ay, num bx, num by, num cx, num cy) {
    final v0x = cx - ax;
    final v0y = cy - ay;
    final v1x = bx - ax;
    final v1y = by - ay;
    final v2x = px - ax;
    final v2y = py - ay;

    final dot00 = v0x * v0x + v0y * v0y;
    final dot01 = v0x * v1x + v0y * v1y;
    final dot02 = v0x * v2x + v0y * v2y;
    final dot11 = v1x * v1x + v1y * v1y;
    final dot12 = v1x * v2x + v1y * v2y;

    final invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
    final num u = (dot11 * dot02 - dot01 * dot12) * invDenom;
    final num v = (dot00 * dot12 - dot01 * dot02) * invDenom;

    return (u >= 0) && (v >= 0) && (u + v < 1);
  }
}
