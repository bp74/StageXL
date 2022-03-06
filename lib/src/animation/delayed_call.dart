part of stagexl.animation;

/// The [DelayedCall] class is used to delay the invocation of
/// a function by a given time.
///
/// See also: [Juggler]
///
/// Examples:
///
///     var action = () => print("Hello world!");
///     var delayedCall = new DelayedCall(action, 1.0);
///     juggler.add(delayedCall);
///
///     var action = () => print("Hello world!");
///     juggler.delayCall(action, 1.0);
///
class DelayedCall implements Animatable {
  final void Function() _action;
  num _currentTime = 0.0;
  num _totalTime = 0.0;


  /// The number of times the delayed call should be executed.
  ///
  /// Default is 1.
  int repeatCount = 1;

  /// Creates a new [DelayedCall].
  ///
  /// The [action] function will be called after the specified [delay] (in
  /// seconds).
  ///
  /// The optional [repeatCount] specifies the number of times the delayed call
  /// should be executed.
  DelayedCall(void Function() action, num delay, {this.repeatCount = 1})
      : _action = action {
    _totalTime = max(delay, 0.0001);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {
    var newTime = _currentTime + time;

    while (newTime >= _totalTime && repeatCount > 0) {
      _currentTime = _totalTime;
      repeatCount--;
      _action();
      newTime -= _totalTime;
    }

    _currentTime = newTime;

    return repeatCount > 0;
  }

  //----------------------------------------------------------------------------

  /// The total time of the delay.
  num get totalTime => _totalTime;

  /// The current time.
  num get currentTime => _currentTime;
}
