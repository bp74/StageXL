part of stagexl.animation;

/// Use the [Tween] class to animate the properties of a display object like
/// x, y, scaleX, scaleY, alpha, rotation etc. The animation starts with the
/// current value of the property and ends at a given target or delta value.
///
/// Use one of the predefined [Transition] functions to control the progress
/// of the animation (linear, easeInQuadratic, easeInCubic, ...). If none of
/// the predefined [Transition] functions fulfills your needs you can also
/// define your own function (see [TransitionFunction]).
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
///     stage.juggler.addTween(mySprite, 1.0, TransitionFunction.easeInCubic)
///       ..delay = 0.5
///       ..animate.alpha.to(0.0);

class Tween implements Animatable {

  final TweenObject _tweenObject;
  final TransitionFunction _transition;
  final List<TweenProperty> _tweenPropertyList = new List<TweenProperty>();

  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime = 0.0;
  num _currentTime = 0.0;
  num _delay = 0.0;
  bool _roundToInt = false;
  bool _started = false;

  /// Creates a new [Tween] for the specified [TweenObject] with a duration
  /// of [time] seconds.
  ///
  /// All display objects implements [TweenObject2D] and all 3D display
  /// additionally objects implements [TweenObject3D]. Therefore all
  /// display objects can be used with with tweens.

  Tween(TweenObject tweenObject, num time, [
        TransitionFunction transition = Transition.linear]) :

    _tweenObject = tweenObject,
    _transition = transition {

    if (_tweenObject is! TweenObject) {
      throw new ArgumentError("tweenObject");
    }

    _totalTime = max(0.0001, time);
  }

  //---------------------------------------------------------------------------

  /// Accessor for 2D properties like x, y, rotation, alpha and others which
  /// can be animated with this tween. Works for all display objects.

  TweenPropertyAccessor2D get animate {
    var tweenObject = _tweenObject;
    if (tweenObject is TweenObject2D) {
      return new TweenPropertyAccessor2D._(this, tweenObject);
    } else {
      throw new StateError("Invalid tween object for 2D animation.");
    }
  }

  /// Accessor for 3D properties like offsetZ, rotationZ and others which
  /// can be animated with this tween. Works for all 3D display objects.

  TweenPropertyAccessor3D get animate3D {
    var tweenObject = _tweenObject;
    if (tweenObject is TweenObject3D) {
      return new TweenPropertyAccessor3D._(this, tweenObject);
    } else {
      throw new StateError("Invalid tween object for 3D animation.");
    }
  }

  TweenProperty _createTweenProperty(TweenPropertyAccessor accessor, int propertyID) {
    var tweenProperty = new TweenProperty._(accessor, propertyID);
    if (_started == false) _tweenPropertyList.add(tweenProperty);
    return tweenProperty;
  }

  //---------------------------------------------------------------------------

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
        num transition = _transition(ratio).toDouble();

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

  //---------------------------------------------------------------------------

  /// Advances this [Tween] to its end state.

  void complete() {
    if (_totalTime >= _currentTime) {
      advanceTime(_totalTime - _currentTime);
    }
  }

  //---------------------------------------------------------------------------

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

  //---------------------------------------------------------------------------

  /// The function that is called when this [Tween] starts.
  ///
  /// This happens after the specified [delay].

  void set onStart(void function()) { _onStart = function; }

  /// The function that is called every time this [Tween] updates the
  /// properties of the [TweenObject].

  void set onUpdate(void function()) { _onUpdate = function; }

  /// The function that is called when this [Tween] is completed.

  void set onComplete(void function()) { _onComplete = function; }
}

