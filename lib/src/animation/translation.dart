part of stagexl.animation;

/// The [Translation] class animates a value by continuously calling
/// the [onUpdate] function.
///
/// Use one of the predefined [Transition] functions to control the progress
/// of the animation (linear, easeInQuadratic, easeInCubic, ...). If none of
/// the predefined [Transition] functions fulfills your needs you can also
/// define your own function (see [TransitionFunction]).
///
/// Examples:
///
///     var translation = new Translation(0.0, 100.0, 1.0, Transition.linear);
///     translation.onUpdate = (value) => print('the value changed to $value');
///     renderLoop.juggler.add(translation);
///
///     var transition = Transition.easeInOutQuadratic;
///     stage.juggler.addTranslation(0.0, 100.0, 1.0, transition, (v) {
///       print('the value changed to $v'));
///     });

class Translation implements Animatable {

  final num _startValue;
  final num _targetValue;
  final TransitionFunction _transition;

  num _currentValue;
  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime = 0.0;
  num _currentTime = 0.0;
  num _delay = 0.0;
  bool _roundToInt = false;
  bool _started = false;

  /// Creates a new [Translation].
  Translation(num startValue, num targetValue, num time, [
              TransitionFunction transition = Transition.linear]) :

    _startValue = startValue,
    _targetValue = targetValue,
    _transition = transition {

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
        num transition = _transition(ratio);

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

  /// The delay before the translation actually starts.
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

  /// Indicates if this [Translation] is completed.
  bool get isComplete => _currentTime >= _totalTime;

  //----------------------------------------------------------------------------

  /// The function that is called when this [Translation] starts.
  ///
  /// This happens after the specified [delay].
  void set onStart(void function()) { _onStart = function; }

  /// The function that is called every time this [Translation] updates the value.
  void set onUpdate(void function(num value)) { _onUpdate = function; }

  /// The function that is called when this [Translation] is completed.
  void set onComplete(void function()) { _onComplete = function; }
}
