part of stagexl.animation;

/// This abstract [Animatable] class declares a common interface
/// for other classes that can be added to the [Juggler].
///
/// See also: [Juggler], [Tween], [Transition], [DelayedCall]
///
/// Example:
///
///     class MyAnimation extends Sprite implements Animatable {
///       num _totalTime = 0.0;
///       bool advanceTime(num time) {
///         _totalTime += time;
///       }
///     }
///
///     var myAnimation = new MyAnimation();
///     juggler.add(myAnimation);
///
abstract class Animatable {

  /// This method is called by the [Juggler] with the [time] past since the last 
  /// call.
  /// 
  /// Returns true as long as this [Animatable] is not completed; false if it
  /// is completed.
  bool advanceTime(num time);
}
