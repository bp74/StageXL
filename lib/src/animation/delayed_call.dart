part of stagexl;

/**
 * The DelayedCall class is used to delay the invocation of
 * a function by a given time.
 *
 * See also: [Juggler]
 *
 * Examples:
 *
 *     var action = () => print("Hello world!");
 *     var delayedCall = new DelayedCall(action, 1.0);
 *     juggler.add(delayedCall);
 *
 *     var action = () => print("Hello world!");
 *     juggler.delayCall(action, 1.0);
 *
 */

class DelayedCall implements Animatable {

  final Function _action;
  num _currentTime = 0.0;
  num _totalTime = 0.0;
  int _repeatCount = 1;

  DelayedCall(Function action, num delay) :
    _action = action {
    _totalTime = max(delay, 0.0001);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time) {

    num newTime = _currentTime + time;

    while (newTime >= _totalTime && _repeatCount > 0) {

      _currentTime = _totalTime;
      _repeatCount--;
      _action();

      newTime -= _totalTime;
    }

    _currentTime = newTime;

    return (_repeatCount > 0);
  }

  //-------------------------------------------------------------------------------------------------

  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  int get repeatCount => _repeatCount;

  set repeatCount(int value) {
    _repeatCount = value;
  }

}
