
typedef TweenFunction(num value);

class _AnimateProperty
{
  String name;
  num startValue;
  num targetValue;

  _AnimateProperty(this.name, this.startValue, this.targetValue);
}

class _AnimateValue
{
  TweenFunction tweenFunction;
  num startValue;
  num targetValue;

  _AnimateValue(this.tweenFunction, this.startValue, this.targetValue);
}

//-----------------------------------------------------------------------------------

class Tween implements IAnimatable
{
  Dynamic _target;
  TransitionFunction _transitionFunction;

  List<_AnimateProperty> _animateProperties;
  List<_AnimateValue> _animateValues;

  Function _onStart;
  Function _onUpdate;
  Function _onComplete;

  num _totalTime;
  num _currentTime;
  num _delay;
  bool _roundToInt;
  bool _started;

  Tween(Dynamic target, num time, [TransitionFunction transitionFunction = null])
  {
    _target = target;
    _transitionFunction = (transitionFunction != null) ? transitionFunction : Transitions.linear;

    _currentTime = 0.0;
    _totalTime = Math.max(0.0001, time);
    _delay = 0.0;
    _roundToInt = false;
    _started = false;

    _animateProperties = new List<_AnimateProperty>();
    _animateValues = new List<_AnimateValue>();
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void animate(String property, num targetValue)
  {
    if (_target != null && _started == false)
      _animateProperties.add(new _AnimateProperty(property, 0.0, targetValue));
  }

  void animateValue(TweenFunction tweenFunction, num startValue, num targetValue)
  {
    if (_started == false)
      _animateValues.add(new _AnimateValue(tweenFunction, startValue, targetValue));
  }

  //-------------------------------------------------------------------------------------------------

  void scaleTo(num factor)
  {
    animate("scaleX", factor);
    animate("scaleY", factor);
  }

  //-------------------------------------------------------------------------------------------------

  void moveTo(num x, num y)
  {
    animate("x", x);
    animate("y", y);
  }

  //-------------------------------------------------------------------------------------------------

  void fadeTo(num alpha)
  {
    animate("alpha", alpha);
  }

  //-------------------------------------------------------------------------------------------------

  void complete()
  {
    if (this.isComplete == false)
      advanceTime(_totalTime - _currentTime);
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    if (_currentTime < _totalTime || _started == false)
    {
      _currentTime = _currentTime + time;

      if (_currentTime > _totalTime)
        _currentTime = _totalTime;

      if (_currentTime >= 0.0)
      {
        if (_started == false)
        {
          _started = true;

          for(int i = 0; i < _animateProperties.length; i++) {
            var ap = _animateProperties[i];
            ap.startValue = _getPropertyValue(_target, ap.name);
          }

          if (_onStart != null)
            _onStart();
        }

        //-------------

        num ratio = _currentTime / _totalTime;
        num transition = _transitionFunction(ratio);

        for(int i = 0; i < _animateProperties.length; i++) {
          var ap = _animateProperties[i];
          var value = ap.startValue + transition * (ap.targetValue - ap.startValue);
          _setPropertyValue(_target, ap.name, _roundToInt ? value.round() : value);
        }

        for(int i = 0; i < _animateValues.length; i++) {
          var av = _animateValues[i];
          var value = av.startValue + transition * (av.targetValue - av.startValue);
          av.tweenFunction(_roundToInt ? value.round() : value);
        }

        if (_onUpdate != null)
          _onUpdate();

        //-------------

        if (_onComplete != null && _currentTime == _totalTime)
          _onComplete();
      }
    }

    return _currentTime < _totalTime;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  Dynamic get target() => _target;
  num get totalTime() => _totalTime;
  num get currentTime() => _currentTime;
  num get delay() => _delay;
  bool get roundToInt() => _roundToInt;
  bool get isComplete() => _currentTime >= _totalTime;

  void set delay(num value)
  {
    if (_started == false)
      _currentTime = _currentTime + _delay - value;

    _delay = value;
  }

  void set roundToInt(bool value)
  {
    _roundToInt = value;
  }

  //-------------------------------------------------------------------------------------------------

  Function get onStart() => _onStart;
  Function get onUpdate() => _onUpdate;
  Function get onComplete() => _onComplete;

  void set onStart(Function value) { _onStart = value; }
  void set onUpdate(Function value) { _onUpdate = value; }
  void set onComplete(Function value) { _onComplete = value; }

  //-------------------------------------------------------------------------------------------------

  _setPropertyValue(Dynamic object, String name, num value)
  {
    switch(name)
    {
      case "x": object.x = value; break;
      case "y": object.y = value; break;
      case "pivotX": object.pivotX = value; break;
      case "pivotY": object.pivotY = value; break;
      case "scaleX": object.scaleX = value; break;
      case "scaleY": object.scaleY = value; break;
      case "rotation": object.rotation = value; break;
      case "alpha": object.alpha = value; break;

      default:
        throw new Exception("Error #9003: The supplied property name ('$name') is not supported at this time.");
    }
  }

  num _getPropertyValue(Dynamic object, String name)
  {
    switch(name)
    {
      case "x": return object.x;
      case "y": return object.y;
      case "pivotX": return object.pivotX;
      case "pivotY": return object.pivotY;
      case "scaleX": return object.scaleX;
      case "scaleY": return object.scaleY;
      case "rotation": return object.rotation;
      case "alpha": return object.alpha;

      default:
        throw new Exception("Error #9003: The supplied property name ('$name') is not supported at this time.");
    }
  }

}
