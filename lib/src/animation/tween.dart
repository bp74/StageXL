part of stagexl;

class TweenPropertyFactory {

  final Tween _tween;

  TweenPropertyFactory._internal(this._tween);

  TweenProperty get x => _tween._addTweenProperty(0);
  TweenProperty get y => _tween._addTweenProperty(1);
  TweenProperty get pivotX => _tween._addTweenProperty(2);
  TweenProperty get pivotY => _tween._addTweenProperty(3);
  TweenProperty get scaleX => _tween._addTweenProperty(4);
  TweenProperty get scaleY => _tween._addTweenProperty(5);
  TweenProperty get skewX => _tween._addTweenProperty(6);
  TweenProperty get skewY => _tween._addTweenProperty(7);
  TweenProperty get rotation => _tween._addTweenProperty(8);
  TweenProperty get alpha => _tween._addTweenProperty(9);
}

class TweenProperty {

  final DisplayObject _displayObject;
  final int _propertyIndex;
  num _startValue = double.NAN;
  num _targetValue = double.NAN;

  TweenProperty._internal(this._displayObject, this._propertyIndex);

  void to(num targetValue) {
    _targetValue = targetValue.toDouble();
  }

  void _init() {
    switch(_propertyIndex) {
      case 0: _startValue = _displayObject.x; break;
      case 1: _startValue = _displayObject.y;  break;
      case 2: _startValue = _displayObject.pivotX; break;
      case 3: _startValue = _displayObject.pivotY; break;
      case 4: _startValue = _displayObject.scaleX; break;
      case 5: _startValue = _displayObject.scaleY; break;
      case 6: _startValue = _displayObject.skewX; break;
      case 7: _startValue = _displayObject.skewY; break;
      case 8: _startValue = _displayObject.rotation; break;
      case 9: _startValue = _displayObject.alpha; break;
      default: _startValue = 0.0;
    }
  }

  void _update(num transition, bool roundToInt) {
    if (_startValue.isFinite && _targetValue.isFinite) {
      var value = _startValue + transition * (_targetValue - _startValue);
      value = roundToInt ? value.roundToDouble() : value;

      switch(_propertyIndex) {
        case 0: _displayObject.x = value; break;
        case 1: _displayObject.y = value;  break;
        case 2: _displayObject.pivotX = value; break;
        case 3: _displayObject.pivotY = value; break;
        case 4: _displayObject.scaleX = value; break;
        case 5: _displayObject.scaleY = value; break;
        case 6: _displayObject.skewX = value; break;
        case 7: _displayObject.skewY = value; break;
        case 8: _displayObject.rotation = value; break;
        case 9: _displayObject.alpha = value; break;
      }
    }
  }
}

//-------------------------------------------------------------------------------------------------

/**
 * The [Tween] class animates the properties of a [DisplayObject].
 * Use one of the [TransitionFunction] functions or create your own.
 * Add the instance to the [Juggler] to start the animation.
 *
 *     var tween = new Tween(mySprite, 1.0, TransitionFunction.easeInCubic);
 *     tween.delay = 0.5;
 *     tween.animate("alpha", 0.0);
 *     tween.onComplete = () => print('completed');
 *     renderLoop.juggler.add(tween);
 **/

class Tween implements Animatable {

  final DisplayObject _displayObject;
  final EaseFunction _transitionFunction;
  final List<TweenProperty> _tweenPropertyList = new List<TweenProperty>();

  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime;
  num _currentTime;
  num _delay;
  bool _roundToInt;
  bool _started;

  Tween(DisplayObject displayObject, num time, [EaseFunction transitionFunction = TransitionFunction.linear]) :

    _displayObject = displayObject,
    _transitionFunction = transitionFunction {

    if (_displayObject is! DisplayObject) {
      throw new ArgumentError("displayObject");
    }

    _currentTime = 0.0;
    _totalTime = max(0.0001, time);
    _delay = 0.0;
    _roundToInt = false;
    _started = false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  TweenPropertyFactory get animate => new TweenPropertyFactory._internal(this);

  TweenProperty _addTweenProperty(int propertyIndex) {
    var tweenProperty = new TweenProperty._internal(_displayObject, propertyIndex);
    if (_started == false) _tweenPropertyList.add(tweenProperty);
    return tweenProperty;
  }

  //-------------------------------------------------------------------------------------------------

  void complete() {
    if (_totalTime >= _currentTime) {
      advanceTime(_totalTime - _currentTime);
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

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

          for(int i = 0; i < _tweenPropertyList.length; i++) {
            _tweenPropertyList[i]._init();
          }
          if (_onStart != null) {
            _onStart();
          }
        }

        // calculate transition ratio and value

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio).toDouble();

        for(int i = 0; i < _tweenPropertyList.length; i++) {
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

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  DisplayObject get displayObject => _displayObject;
  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  num get delay => _delay;
  bool get roundToInt => _roundToInt;
  bool get isComplete => _currentTime >= _totalTime;

  set delay(num value) {
    if (_started == false) {
      _currentTime = _currentTime + _delay - value;
    }
    _delay = value;
  }

  set roundToInt(bool value) {
    _roundToInt = value;
  }

  //-------------------------------------------------------------------------------------------------

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
