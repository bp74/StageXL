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

  Tween(TweenObject tweenObject, num time,
      [EaseFunction transitionFunction = TransitionFunction.linear]) :

    _tweenObject = tweenObject,
    _transitionFunction = transitionFunction {

    if (_tweenObject is! TweenObject) {
      throw new ArgumentError("tweenObject");
    }

    _totalTime = max(0.0001, time);
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  TweenPropertyFactory get animate => new TweenPropertyFactory._internal(this);

  TweenProperty _addTweenProperty(int propertyIndex) {
    var tweenProperty = new TweenProperty._internal(_tweenObject, propertyIndex);
    if (_started == false) _tweenPropertyList.add(tweenProperty);
    return tweenProperty;
  }

  //-----------------------------------------------------------------------------------------------

  void complete() {
    if (_totalTime >= _currentTime) {
      advanceTime(_totalTime - _currentTime);
    }
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

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

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  TweenObject get tweenObject => _tweenObject;
  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  num get delay => _delay;
  bool get roundToInt => _roundToInt;
  bool get isComplete => _currentTime >= _totalTime;

  set delay(num value) {
    if (_started == false) {
      _currentTime = _currentTime + _delay - value;
      _delay = value;
    }
  }

  set roundToInt(bool value) {
    _roundToInt = value;
  }

  //-----------------------------------------------------------------------------------------------

  /**
   * The function that is called when a [Tween] starts. This happens after the specified delay.
   **/
  void set onStart(void function()) { _onStart = function; }

  /**
   * The function that is called every time a [Tween] updates the properties of the [DisplayObject].
   **/
  void set onUpdate(void function()) { _onUpdate = function; }

  /**
   * The function that is called when a [Tween] is completed.
   **/
  void set onComplete(void function()) { _onComplete = function; }
}

