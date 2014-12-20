part of stagexl.animation;

/// The [Transition] class animates a value by calling the [onUpdate]
/// function continuously.
///
/// See also: [Juggler]
///
/// Examples:
///
///     var transition = new Transition(0.0, 100.0, 1.0, TransitionFunction.linear);
///     transition.onUpdate = (value) => print('the value changed to $value');
///     renderLoop.juggler.add(transition);
///
///     vare easeFunction = TransitionFunction.easeInOutQuadratic;
///     stage.juggler.transition(0.0, 100.0, 1.0, easeFunction, (v) => {
///       print('the value changed to $v'));
///     });
///
class Transition implements Animatable {
  final num _startValue;
  final num _targetValue;
  final EaseFunction _transitionFunction;

  num _currentValue;
  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime = 0.0;
  num _currentTime = 0.0;
  num _delay = 0.0;
  bool _roundToInt = false;
  bool _started = false;

  /// Creates a new [Transition].
  Transition(num startValue, num targetValue, num time,
      [EaseFunction transitionFunction = TransitionFunction.linear]) :

    _startValue = startValue,
    _targetValue = targetValue,
    _transitionFunction = transitionFunction {

    _currentValue = startValue;
    _totalTime = max(0.0001, time);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {
    if (_currentTime < _totalTime || _started == false) {
      _currentTime = _currentTime + time;

      if (_currentTime > _totalTime) _currentTime = _totalTime;

      if (_currentTime >= 0.0) {
        if (_started == false) {
          _started = true;
          if (_onStart != null) _onStart();
        }

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio);

        _currentValue = _startValue + transition * (_targetValue - _startValue);

        if (_onUpdate != null) _onUpdate(_roundToInt ? _currentValue.round() : _currentValue);
        if (_onComplete != null && _currentTime == _totalTime) _onComplete();
      }
    }

    return _currentTime < _totalTime;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// The starting value to animate from.
  num get startValue => _startValue;

  /// The value to animate to.
  num get targetValue => _targetValue;

  /// The current value.
  ///
  /// If [roundToInt] is true, this value will always be an [int].
  num get currentValue => _roundToInt ? _currentValue.round() : _currentValue;

  /// The total time of this [Animation].
  num get totalTime => _totalTime;

  /// The current time of this [Animation].
  num get currentTime => _currentTime;

  /// The delay this [Transiation] waits until it starts animating.
  ///
  /// The delay may be changed as long as the animation has not been started.
  num get delay => _delay;

  set delay(num value) {
    if (_started == false) {
      _currentTime = _currentTime + _delay - value;
      _delay = value;
    }
  }

  /// Specifies if the values should be rounded to an integer.
  ///
  /// Default is false.
  bool get roundToInt => _roundToInt;

  set roundToInt(bool value) {
    _roundToInt = value;
  }

  /// Indicates if this [Transition] is completed.
  bool get isComplete => _currentTime >= _totalTime;

  //----------------------------------------------------------------------------

  /// The function that is called when this [Transition] starts. 
  /// 
  /// This happens after the specified [delay].
  void set onStart(void function()) { _onStart = function; }

  /// The function that is called every time this [Transition] updates the value.
  void set onUpdate(void function(num value)) { _onUpdate = function; }

  /// The function that is called when this [Transition] is completed.
  void set onComplete(void function()) { _onComplete = function; }
}
