part of stagexl;

class TweenPropertyFactory {

  final Tween tween;
  TweenPropertyFactory(this.tween);

  @deprecated
  call(String property, num targetValue) {
    _addTweenProperty(property).to(targetValue);
  }

  TweenProperty get x => _addTweenProperty("x");
  TweenProperty get y => _addTweenProperty("y");
  TweenProperty get scaleX => _addTweenProperty("scaleX");
  TweenProperty get scaleY => _addTweenProperty("scaleY");
  TweenProperty get skewX => _addTweenProperty("skewX");
  TweenProperty get skewY => _addTweenProperty("skewY");
  TweenProperty get pivotX => _addTweenProperty("pivotX");
  TweenProperty get pivotY => _addTweenProperty("pivotY");
  TweenProperty get rotation => _addTweenProperty("rotation");
  TweenProperty get alpha => _addTweenProperty("alpha");

  TweenProperty _addTweenProperty(String property) {
    var tweenProperty = new TweenProperty(property);
    this.tween._addTweenProperty(tweenProperty);
    return tweenProperty;
  }
}

class TweenProperty {

  final String property;
  num startValue = double.NAN;
  num targetValue = double.NAN;

  TweenProperty(this.property);

  void to(num targetValue) {
    this.targetValue = targetValue.toDouble();
  }

  bool get isDefined => !startValue.isNaN && !targetValue.isNaN;

  num _getPropertyValue(DisplayObject displayObject) {
    switch(property) {
      case 'x':        return displayObject.x;
      case 'y':        return displayObject.y;
      case 'pivotX':   return displayObject.pivotX;
      case 'pivotY':   return displayObject.pivotY;
      case 'scaleX':   return displayObject.scaleX;
      case 'scaleY':   return displayObject.scaleY;
      case 'skewX':    return displayObject.skewX;
      case 'skewY':    return displayObject.skewY;
      case 'rotation': return displayObject.rotation;
      case 'alpha':    return displayObject.alpha;
      default:         return 0.0;
    }
  }

  void _setPropertyValue(DisplayObject displayObject, num value) {
    switch(property) {
      case 'x':        displayObject.x = value; break;
      case 'y':        displayObject.y = value; break;
      case 'pivotX':   displayObject.pivotX = value; break;
      case 'pivotY':   displayObject.pivotY = value; break;
      case 'scaleX':   displayObject.scaleX = value; break;
      case 'scaleY':   displayObject.scaleY = value; break;
      case 'skewX':    displayObject.skewX = value; break;
      case 'skewY':    displayObject.skewY = value; break;
      case 'rotation': displayObject.rotation = value; break;
      case 'alpha':    displayObject.alpha = value; break;
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

  TweenPropertyFactory _tweenPropertyFactory;
  num _totalTime;
  num _currentTime;
  num _delay;
  bool _roundToInt;
  bool _started;

  Tween(DisplayObject displayObject, num time, [EaseFunction transitionFunction = TransitionFunction.linear]) :

    _displayObject = displayObject,
    _transitionFunction = transitionFunction {

    _tweenPropertyFactory = new TweenPropertyFactory(this);
    _currentTime = 0.0;
    _totalTime = max(0.0001, time);
    _delay = 0.0;
    _roundToInt = false;
    _started = false;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  TweenPropertyFactory get animate => _tweenPropertyFactory;

  void _addTweenProperty(TweenProperty tweenProperty) {

    if (_displayObject != null && _started == false) {
      _tweenPropertyList.add(tweenProperty);
    }
  }

  //-------------------------------------------------------------------------------------------------

  void complete() {
    if (_totalTime >= _currentTime)
      advanceTime(_totalTime - _currentTime);
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
            var tp = _tweenPropertyList[i];
            tp.startValue = tp._getPropertyValue(_displayObject);
          }
          if (_onStart != null) {
            _onStart();
          }
        }

        // calculate transition ratio and value

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio).toDouble();

        for(int i = 0; i < _tweenPropertyList.length; i++) {
          var tp = _tweenPropertyList[i];
          if (tp.isDefined) {
            var startValue = tp.startValue.toDouble();
            var targetValue = tp.targetValue.toDouble();
            var value = startValue + transition * (targetValue - startValue);
            tp._setPropertyValue(_displayObject, _roundToInt ? value.round() : value);
          }
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

    if (_started == false)
      _currentTime = _currentTime + _delay - value;

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
