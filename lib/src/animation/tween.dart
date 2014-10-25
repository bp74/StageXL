part of stagexl.animation;

/// Use the [Tween] class to animate the properties of a display object like
/// x, y, scaleX, scaleY, alpha, rotation etc. The animation starts with the
/// current value of the property and ends at a given target or delta value.
///
/// Use one of the predefined [TransitionFunction] functions to control the
/// progress of the animation (linear, easeInQuadratic, easeInCubic, ...). If
/// none of the predefined [TransitionFunction] functions fulfills your needs
/// you can also use one of your own function (see [EaseFunction]).
///
/// See also: [Juggler]
///
/// Examples:
///
///     var tween = new Tween(mySprite, 1.0, TransitionFunction.easeInCubic);
///     tween.delay = 0.5;
///     tween.animate.alpha.to(0.0);  // target value = 0.0
///     tween.animate.x.by(10.0);     // delta value = 10.0;
///     tween.animate.y.by(-10.0);    // delta value = -10.0;
///     tween.onComplete = () => print('completed');
///     stage.juggler.add(tween);
///
///     var sawtooth = Tween(mySprite, 1.0, (r) => (r * 4).remainder(1.0);
///     sawtooth.animate.y.to(10);
///     stage.juggler.add(sawtooth);
///
///     stage.juggler.tween(mySprite, 1.0, TransitionFunction.easeInCubic)
///       ..delay = 0.5
///       ..animate.alpha.to(0.0);
///
class Tween implements Animatable {

  final TweenObject _tweenObject;
  final EaseFunction _transitionFunction;
  final List<TweenProperty> _tweenPropertyList = new List<TweenProperty>();

  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime = 0.0;
  num _currentTime = 0.0;
  num _delay = 0.0;
  bool _roundToInt = false;
  bool _started = false;

  /// Creates a new [Tween] for the specified [tweenObject] with a duration
  /// of [time] seconds.
  Tween(TweenObject tweenObject, num time,
      [EaseFunction transitionFunction = TransitionFunction.linear]) :

    _tweenObject = tweenObject,
    _transitionFunction = transitionFunction {

    if (_tweenObject is! TweenObject) {
      throw new ArgumentError("tweenObject");
    }

    _totalTime = max(0.0001, time);
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Accessor for the [TweenPropertyFactory] to specify what properties 
  /// should be animated by this [Tween].
  TweenPropertyFactory get animate => new TweenPropertyFactory._internal(this);

  TweenProperty _addTweenProperty(int propertyIndex) {
    var tweenProperty = new TweenProperty._internal(_tweenObject, propertyIndex);
    if (_started == false) _tweenPropertyList.add(tweenProperty);
    return tweenProperty;
  }

  //----------------------------------------------------------------------------

  /// Advances this [Tween] to its end state.
  void complete() {
    if (_totalTime >= _currentTime) {
      advanceTime(_totalTime - _currentTime);
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {

    if (_currentTime < _totalTime || _started == false) {

      _currentTime = _currentTime + time;

      if (_currentTime > _totalTime) {
        _currentTime = _totalTime;
      }

      if (_currentTime >= 0.0) {

        // set startValues if this is the first start

        if (_started == false) {
          _started = true;

          for (int i = 0; i < _tweenPropertyList.length; i++) {
            _tweenPropertyList[i]._init();
          }
          if (_onStart != null) {
            _onStart();
          }
        }

        // calculate transition ratio and value

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio).toDouble();

        for (int i = 0; i < _tweenPropertyList.length; i++) {
          _tweenPropertyList[i]._update(transition, _roundToInt);
        }
        if (_onUpdate != null) {
          _onUpdate();
        }
        if (_onComplete != null && _currentTime == _totalTime) {
          _onComplete();
        }
      }
    }

    return _currentTime < _totalTime;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// The object that is tweened.
  TweenObject get tweenObject => _tweenObject;
  
  /// The total time of this [Tween].
  num get totalTime => _totalTime;
  
  /// The current time of this [Tween].
  num get currentTime => _currentTime;

  /// The delay this [Tween] waits until it starts animating.
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
  
  /// Indicates if this [Tween] is completed.
  bool get isComplete => _currentTime >= _totalTime;

  //----------------------------------------------------------------------------

  /// The function that is called when this [Tween] starts. 
  /// 
  /// This happens after the specified [delay].
  void set onStart(void function()) { _onStart = function; }

  /// The function that is called every time this [Tween] updates the properties 
  /// of the [TweenObject].
  void set onUpdate(void function()) { _onUpdate = function; }

  /// The function that is called when this [Tween] is completed.
  void set onComplete(void function()) { _onComplete = function; }
}

