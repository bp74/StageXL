library stagexl.geom.rectangle;

import 'dart:math' hide Point, Rectangle;
import 'dart:math' as math;

import '../internal/jenkins_hash.dart';
import 'point.dart';

class Rectangle<T extends num> implements math.MutableRectangle<T> {
  @override
  T left;

  @override
  T top;

  @override
  T width;

  @override
  T height;

  Rectangle(this.left, this.top, this.width, this.height);

  Rectangle.from(math.Rectangle<T> r) : this(r.left, r.top, r.width, r.height);

  Rectangle<T> clone() => Rectangle<T>(left, top, width, height);

  @override
  String toString() =>
      'Rectangle<$T> [left=$left, top=$top, width=$width, height=$height]';

  //---------------------------------------------------------------------------
  //---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) =>
      other is math.Rectangle &&
      left == other.left &&
      top == other.top &&
      width == other.width &&
      height == other.height;

  @override
  int get hashCode {
    final a = left.hashCode;
    final b = top.hashCode;
    final c = width.hashCode;
    final d = height.hashCode;
    return JenkinsHash.hash4(a, b, c, d);
  }

  //---------------------------------------------------------------------------

  Point<num> get center => Point<num>(left + width / 2, top + height / 2);

  bool get isEmpty => width <= 0 || height <= 0;

  @override
  T get right => left + width as T;

  set right(T value) {
    width = value - left as T;
  }

  @override
  T get bottom => top + height as T;

  set bottom(T value) {
    height = value - top as T;
  }

  @override
  Point<T> get topLeft => Point<T>(left, top);

  set topLeft(Point<T> point) {
    width = width + left - point.x as T;
    height = height + top - point.y as T;
    left = point.x;
    top = point.y;
  }

  @override
  Point<T> get topRight => Point<T>(right, top);

  set topRight(Point<T> point) {
    width = point.x - left as T;
    height = height + top - point.y as T;
    top = point.y;
  }

  @override
  Point<T> get bottomLeft => Point<T>(left, bottom);

  set bottomLeft(Point<T> point) {
    width = width + left - point.x as T;
    height = point.y - top as T;
    left = point.x;
  }

  @override
  Point<T> get bottomRight => Point<T>(right, bottom);

  set bottomRight(Point<T> point) {
    width = point.x - left as T;
    height = point.y - top as T;
  }

  Point<T> get size => Point<T>(width, height);

  set size(Point<T> point) {
    width = point.x;
    height = point.y;
  }

  //---------------------------------------------------------------------------

  bool contains(num px, num py) =>
      left <= px && top <= py && right > px && bottom > py;

  @override
  bool containsPoint(math.Point<num> p) => contains(p.x, p.y);

  @override
  bool intersects(math.Rectangle<num> r) =>
      left < r.right && right > r.left && top < r.bottom && bottom > r.top;

  /// Returns a rectangle which completely contains `this` and [other].

  @override
  Rectangle<T> boundingBox(math.Rectangle<T> other) {
    final rLeft = min(left, other.left);
    final rTop = min(top, other.top);
    final rRight = max(right, other.right);
    final rBottom = max(bottom, other.bottom);
    return Rectangle<T>(rLeft, rTop, rRight - rLeft as T, rBottom - rTop as T);
  }

  /// Tests whether `this` entirely contains [another].

  @override
  bool containsRectangle(math.Rectangle<num> r) =>
      left <= r.left && top <= r.top && right >= r.right && bottom >= r.bottom;

  //---------------------------------------------------------------------------

  void copyFrom(math.Rectangle<T> r) {
    setTo(r.left, r.top, r.width, r.height);
  }

  void inflate(T dx, T dy) {
    width = width + dx as T;
    height = height + dy as T;
  }

  void inflatePoint(math.Point<T> p) {
    inflate(p.x, p.y);
  }

  void offset(T dx, T dy) {
    left = left + dx as T;
    top = top + dy as T;
  }

  void offsetPoint(Point<T> p) {
    offset(p.x, p.y);
  }

  void setTo(T rx, T ry, T rwidth, T rheight) {
    left = rx;
    top = ry;
    width = rwidth;
    height = rheight;
  }

  @override
  Rectangle<T> intersection(math.Rectangle<T> rect) {
    final rLeft = max(left, rect.left);
    final rTop = max(top, rect.top);
    final rRight = min(right, rect.right);
    final rBottom = min(bottom, rect.bottom);
    return Rectangle<T>(rLeft, rTop, rRight - rLeft as T, rBottom - rTop as T);
  }

  Rectangle<int> align() {
    final rLeft = left.floor();
    final rTop = top.floor();
    final rRight = right.ceil();
    final rBottom = bottom.ceil();
    return Rectangle<int>(rLeft, rTop, rRight - rLeft, rBottom - rTop);
  }
}
