part of stagexl;

class Circle<T extends num> {

  T x;
  T y;
  T radius;

  Circle(this.x, this.y, this.radius);

  Circle clone() => new Circle(x, y, radius);

  String toString() => "Circle<$T> [x=$x, y=$y, radius=$radius]";

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool contains(num x, num y) {
    var dx = this.x - x;
    var dy = this.y - y;
    return dx * dx + dy * dy < radius * radius;
  }

  bool containsPoint(Point<num> p) {
    var dx = this.x - p.x;
    var dy = this.y - p.y;
    return dx * dx + dy * dy < radius * radius;
  }
}
