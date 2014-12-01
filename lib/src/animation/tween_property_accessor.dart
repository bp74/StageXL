part of stagexl.animation;

/// The abstract base class for [TweenPropertyAccessor2D] and
/// [TweenPropertyAccessor3D]. Those accessors are returned by
/// the [Tween.animate] and [Tween.animate3D] getters.

abstract class TweenPropertyAccessor {
  num _getValue(int propertyID);
  void _setValue(int propertyID, num value);
}

/// The [TweenPropertyAccessor2D] is used to access the animatable
/// properties of a [TweenObject2D]. This class is return by the
/// [Tween.animate] getter.

class TweenPropertyAccessor2D implements TweenPropertyAccessor {

  final Tween _tween;
  final TweenObject2D _tweenObject;

  TweenPropertyAccessor2D._(this._tween, this._tweenObject);

  TweenProperty get x => _tween._createTweenProperty(this, 0);
  TweenProperty get y => _tween._createTweenProperty(this, 1);
  TweenProperty get pivotX => _tween._createTweenProperty(this, 2);
  TweenProperty get pivotY => _tween._createTweenProperty(this, 3);
  TweenProperty get scaleX => _tween._createTweenProperty(this, 4);
  TweenProperty get scaleY => _tween._createTweenProperty(this, 5);
  TweenProperty get skewX => _tween._createTweenProperty(this, 6);
  TweenProperty get skewY => _tween._createTweenProperty(this, 7);
  TweenProperty get rotation => _tween._createTweenProperty(this, 8);
  TweenProperty get alpha => _tween._createTweenProperty(this, 9);

  num _getValue(int propertyID) {
    switch(propertyID) {
      case 0: return _tweenObject.x;
      case 1: return _tweenObject.y;
      case 2: return _tweenObject.pivotX;
      case 3: return _tweenObject.pivotY;
      case 4: return _tweenObject.scaleX;
      case 5: return _tweenObject.scaleY;
      case 6: return _tweenObject.skewX;
      case 7: return _tweenObject.skewY;
      case 8: return _tweenObject.rotation;
      case 9: return _tweenObject.alpha;
      default: return 0.0;
    }
  }

  void _setValue(int propertyID, num value) {
    switch(propertyID) {
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

/// The [TweenPropertyAccessor3D] is used to access the animatable
/// properties of a [TweenObject3D]. This class is return by the
/// [Tween.animate3D] getter.

class TweenPropertyAccessor3D implements TweenPropertyAccessor {

  final Tween _tween;
  final TweenObject3D _tweenObject;

  TweenPropertyAccessor3D._(this._tween, this._tweenObject);

  TweenProperty get offsetX => _tween._createTweenProperty(this, 0);
  TweenProperty get offsetY => _tween._createTweenProperty(this, 1);
  TweenProperty get offsetZ => _tween._createTweenProperty(this, 2);
  TweenProperty get rotationX => _tween._createTweenProperty(this, 3);
  TweenProperty get rotationY => _tween._createTweenProperty(this, 4);
  TweenProperty get rotationZ => _tween._createTweenProperty(this, 5);

  num _getValue(int propertyID) {
    switch(propertyID) {
      case 0: return _tweenObject.offsetX;
      case 1: return _tweenObject.offsetY;
      case 2: return _tweenObject.offsetZ;
      case 3: return _tweenObject.rotationX;
      case 4: return _tweenObject.rotationY;
      case 5: return _tweenObject.rotationZ;
      default: return 0.0;
    }
  }

  void _setValue(int propertyID, num value) {
    switch(propertyID) {
      case 0: _tweenObject.offsetX = value; break;
      case 1: _tweenObject.offsetY = value;  break;
      case 2: _tweenObject.offsetZ = value; break;
      case 3: _tweenObject.rotationX = value; break;
      case 4: _tweenObject.rotationY = value; break;
      case 5: _tweenObject.rotationZ = value; break;
    }
  }
}
