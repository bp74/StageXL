library stagexl.geom.circle;

import 'point.dart';
import '../internal/jenkins_hash.dart';

class Circle<T extends num> {

  T x;
  T y;
  T radius;

  Circle(this.x, this.y, this.radius);

  Circle clone() => new Circle(x, y, radius);

  String toString() => "Circle<$T> [x=$x, y=$y, radius=$radius]";

  //---------------------------------------------------------------------------

  bool operator ==(other) {
    return other is Circle &&
        this.x == other.x &&
        this.y == other.y &&
        this.radius == other.radius;
  }

  int get hashCode {
    int a = this.x.hashCode;
    int b = this.y.hashCode;
    int c = this.radius.hashCode;
    return JenkinsHash.hash3(a, b, c);
  }

  //---------------------------------------------------------------------------

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
