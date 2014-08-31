part of stagexl.animation;

/// The abstract [TweenObject] class defines the interface for a class
/// that can used with the [Tween] class. All DisplayObjects do implement
/// this interface and therefore they can be used for tween animations.
///
abstract class TweenObject {
  num x, y;
  num pivotX, pivotY;
  num scaleX, scaleY;
  num skewX, skewY;
  num rotation;
  num alpha;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/// The [TweenPropertyFactory] is returned by the [Tween.animate] method
/// and is used to access the animatable properties of a [TweenObject].
///
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

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/// The [TweenProperty] class is used by the [TweenPropertyFactory] to
/// access a property of the [TweenObject] class.
///
class TweenProperty {

  final TweenObject _tweenObject;
  final int _propertyIndex;
  num _startValue = double.NAN;
  num _targetValue = double.NAN;
  num _deltaValue =  double.NAN;

  TweenProperty._internal(this._tweenObject, this._propertyIndex);

  /// Animate the property from the current value to a given target value.
  void to(num targetValue) {
    _targetValue = targetValue.toDouble();
  }

  /// Animate the property from the current value by a given delta value.
  void by(num deltaValue) {
    _deltaValue = deltaValue.toDouble();
  }

  void _init() {
    switch(_propertyIndex) {
      case 0: _startValue = _tweenObject.x; break;
      case 1: _startValue = _tweenObject.y;  break;
      case 2: _startValue = _tweenObject.pivotX; break;
      case 3: _startValue = _tweenObject.pivotY; break;
      case 4: _startValue = _tweenObject.scaleX; break;
      case 5: _startValue = _tweenObject.scaleY; break;
      case 6: _startValue = _tweenObject.skewX; break;
      case 7: _startValue = _tweenObject.skewY; break;
      case 8: _startValue = _tweenObject.rotation; break;
      case 9: _startValue = _tweenObject.alpha; break;
      default: _startValue = 0.0;
    }

    if (_deltaValue.isNaN && _targetValue.isFinite) {
      _deltaValue = _targetValue - _startValue;
    }
    if (_targetValue.isNaN && _deltaValue.isFinite) {
      _targetValue = _startValue + _deltaValue;
    }
  }

  void _update(num transition, bool roundToInt) {
    if (_startValue.isFinite && _targetValue.isFinite) {
      var value = _startValue + transition * (_targetValue - _startValue);
      value = roundToInt ? value.roundToDouble() : value;

      switch(_propertyIndex) {
        case 0: _tweenObject.x = value; break;
        case 1: _tweenObject.y = value;  break;
        case 2: _tweenObject.pivotX = value; break;
        case 3: _tweenObject.pivotY = value; break;
        case 4: _tweenObject.scaleX = value; break;
        case 5: _tweenObject.scaleY = value; break;
        case 6: _tweenObject.skewX = value; break;
        case 7: _tweenObject.skewY = value; break;
        case 8: _tweenObject.rotation = value; break;
        case 9: _tweenObject.alpha = value; break;
      }
    }
  }
}
