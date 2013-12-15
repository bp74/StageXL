part of stagexl;

/**
 * The AnimationGroup class is used to animate multiple Animatables.
 * Those Animatables are animated in parallel and the onComplete
 * callback is called when all Animatables have completed.
 *
 * See also: [Juggler], [AnimationGroup], [Animatable]
 *
 * Examples:
 *
 *     var ag = new AnimationGroup();
 *     ag.add(new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700));
 *     ag.add(new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500));
 *     ag.delay = 1.0;
 *     ag.onStart = () => print("start");
 *     ag.onComplete = () => print("complete");
 *     juggler.add(ag);
 *
 *     juggler.addGroup([
 *         new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700),
 *         new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500)])
 *         ..onComplete = () => print("complete");
 *
 */

class AnimationGroup implements Animatable {

  final List<Animatable> _animatables = new List<Animatable>();

  Function _onStart;
  Function _onComplete;

  num _time = 0.0;
  num _delay = 0.0;
  bool _started = false;
  bool _completed = false;

  //-------------------------------------------------------------------------------------------------

  void add(Animatable animatable) {
    _animatables.add(animatable);
  }

  bool advanceTime(num time) {

    _time += time;

    if (_started == false) {
      if (_time > _delay) {
        _started = true;
        if (_onStart != null) _onStart();
      } else {
        return true;
      }
    }

    for(int i = 0; i < _animatables.length; ) {
      if (_animatables[i].advanceTime(time) == false) {
        _animatables.removeAt(i);
      } else {
        i++;
      }
    }

    if (_animatables.length == 0) {
      _completed = true;
      if (_onComplete != null) _onComplete();
      return false;
    } else {
      return true;
    }
  }

  //-------------------------------------------------------------------------------------------------

  num get delay => _delay;
  bool get isComplete => _completed;

  set delay(num value) {
    if (_started == false) {
      _time = _time + _delay - value;
      _delay = value;
    }
  }

  //-------------------------------------------------------------------------------------------------

  /// The function that is called when a [AnimationGroup] starts.
  /// This happens after the specified delay.
  void set onStart(void function()) { _onStart = function; }

  /// The function that is called when a [AnimationGroup] is completed.
  void set onComplete(void function()) { _onComplete = function; }
}