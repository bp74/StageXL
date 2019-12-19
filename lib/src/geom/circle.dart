library stagexl.geom.circle;

import 'point.dart';
import '../internal/jenkins_hash.dart';

class Circle<T extends num> {
  T x;
  T y;
  T radius;

  Circle(this.x, this.y, this.radius);

  Circle clone() => Circle(x, y, radius);

  @override
  String toString() => 'Circle<$T> [x=$x, y=$y, radius=$radius]';

  //---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    return other is Circle &&
        x == other.x &&
        y == other.y &&
        radius == other.radius;
  }

  @override
  int get hashCode {
    var a = x.hashCode;
    var b = y.hashCode;
    var c = radius.hashCode;
    return JenkinsHash.hash3(a, b, c);
  }

  //---------------------------------------------------------------------------

  bool contains(num x, num y) {
    var dx = this.x - x;
    var dy = this.y - y;
    return dx * dx + dy * dy < radius * radius;
  }

  bool containsPoint(Point<num> p) {
    var dx = x - p.x;
    var dy = y - p.y;
    return dx * dx + dy * dy < radius * radius;
  }
}
