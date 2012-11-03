part of dartflash;

/// The function that is called when a [Transition] starts. This happens after the specified delay.
typedef void TransitionStart();
/// The function that is called every time a [Transition] updates the value.
typedef void TransitionUpdate(num value);
/// The function that is called when a [Transition] is completed.
typedef void TransitionComplete();

/**
 * The [Transition] class animates a value by calling the [onUpdate] function continuously.
 *
 *     var transition = new Transition(0.0, 100.0, 1.0, Transitions.linear);
 *     transition.onUpdate = (value) => print('the value changed to $value');
 *     renderLoop.juggler.add(transition);
 **/

class Transition extends Animatable
{
  num _startValue;
  num _targetValue;
  num _currentValue;

  TransitionFunction _transitionFunction;

  TransitionStart _onStart;
  TransitionUpdate _onUpdate;
  TransitionComplete _onComplete;

  num _totalTime;
  num _currentTime;
  num _delay;
  bool _roundToInt;
  bool _started;

  Transition(num startValue, num targetValue, num time, [TransitionFunction transitionFunction = null])
  {
    _startValue = startValue;
    _targetValue = targetValue;
    _currentValue = startValue;

    _transitionFunction = (transitionFunction != null) ? transitionFunction : Transitions.linear;

    _currentTime = 0.0;
    _totalTime = max(0.0001, time);
    _delay = 0.0;
    _roundToInt = false;
    _started = false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    if (_currentTime < _totalTime || _started == false)
    {
      _currentTime = _currentTime + time;

      if (_currentTime > _totalTime)
        _currentTime = _totalTime;

      if (_currentTime >= 0.0)
      {
        if (_started == false) {
          _started = true;

          if (_onStart != null)
            _onStart();
        }

        //-------------

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio);

        _currentValue = _startValue + transition * (_targetValue - _startValue);

        if (_onUpdate != null)
          _onUpdate(_roundToInt ? _currentValue.round() : _currentValue);

        //-------------

        if (_onComplete != null && _currentTime == _totalTime)
          _onComplete();
      }
    }

    return _currentTime < _totalTime;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get startValue => _startValue;
  num get targetValue => _targetValue;
  num get currentValue => _roundToInt ? _currentValue.round() : _currentValue;

  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  num get delay => _delay;

  bool get roundToInt => _roundToInt;
  bool get isComplete => _currentTime >= _totalTime;

  set delay(num value)
  {
    if (_started == false)
      _currentTime = _currentTime + _delay - value;

    _delay = value;
  }

  set roundToInt(bool value)
  {
    _roundToInt = value;
  }

  //-------------------------------------------------------------------------------------------------

  TransitionStart get onStart => _onStart;
  TransitionUpdate get onUpdate => _onUpdate;
  TransitionComplete get onComplete => _onComplete;

  void set onStart(TransitionStart value) { _onStart = value; }
  void set onUpdate(TransitionUpdate value) { _onUpdate = value; }
  void set onComplete(TransitionComplete value) { _onComplete = value; }
}
