part of stagexl.animation;

/// The [TweenProperty] class controls the value of a property while
/// the tween is running. This class is returned by the getters of
/// the [TweenPropertyAccessor] implementations.

class TweenProperty {
  final TweenPropertyAccessor _tweenPropertyAccessor;
  final int _propertyID;

  num _startValue = double.NAN;
  num _targetValue = double.NAN;
  num _deltaValue = double.NAN;

  TweenProperty._(this._tweenPropertyAccessor, this._propertyID);

  /// Animate the property from the current value to a given target value.

  void to(num targetValue) {
    _targetValue = targetValue.toDouble();
  }

  /// Animate the property from the current value by a given delta value.

  void by(num deltaValue) {
    _deltaValue = deltaValue.toDouble();
  }

  void _init() {

    _startValue = _tweenPropertyAccessor._getValue(_propertyID);

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
      _tweenPropertyAccessor._setValue(_propertyID, value);
    }
  }
}
