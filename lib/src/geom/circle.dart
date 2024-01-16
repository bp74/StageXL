import '../internal/jenkins_hash.dart';
import 'point.dart';

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
  bool operator ==(Object other) =>
      other is Circle && x == other.x && y == other.y && radius == other.radius;

  @override
  int get hashCode {
    final a = x.hashCode;
    final b = y.hashCode;
    final c = radius.hashCode;
    return JenkinsHash.hash3(a, b, c);
  }

  //---------------------------------------------------------------------------

  bool contains(num x, num y) {
    final dx = this.x - x;
    final dy = this.y - y;
    return dx * dx + dy * dy < radius * radius;
  }

  bool containsPoint(Point<num> p) {
    final dx = x - p.x;
    final dy = y - p.y;
    return dx * dx + dy * dy < radius * radius;
  }
}
