part of stagexl;

/**
 * The AnimationChain class is used to animate multiple Animatables.
 * Those Animatables are animated one after the other and the onComplete
 * callback is called when the last Animatable has completed.
 *
 * See also: [Juggler], [AnimationChain], [Animatable]
 *
 * Examples:
 *
 *     var ac = new AnimationChain();
 *     ac.add(new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700));
 *     ac.add(new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500));
 *     ac.delay = 1.0;
 *     ac.onStart = () => print("start");
 *     ac.onComplete = () => print("complete");
 *     juggler.add(ac);
 *
 *     juggler.addChain([
 *         new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700),
 *         new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500)])
 *         ..onComplete = () => print("complete");
 *
 */

class AnimationChain implements Animatable {

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

    if (_animatables.length > 0) {
      if (_animatables[0].advanceTime(time) == false) {
        _animatables.removeAt(0);
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

  /* The function that is called when a [AnimationChain] starts.
   * This happens after the specified delay.
   */
  void set onStart(void function()) { _onStart = function; }

  /* The function that is called when a [AnimationChain] is completed.
   */
  void set onComplete(void function()) { _onComplete = function; }
}