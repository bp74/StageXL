part of stagexl;

/// The AnimationGroup is used to group Animatables and
/// offers a common onStart and onComplete callback.
/// The other Animatables are animated in a sequence.
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