part of dartflash;

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

class Tween implements Animatable
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
    _totalTime = max(0.0001, time);
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
    var properties = ['x', 'y', 'pivotX', 'pivotY', 'scaleX', 'scaleY', 'rotation', 'alpha'];

    if (properties.indexOf(property) == -1)
      throw new ArgumentError("Error #9003: The supplied property ('$property') is not supported at this time.");

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
    animate('scaleX', factor);
    animate('scaleY', factor);
  }

  //-------------------------------------------------------------------------------------------------

  void moveTo(num x, num y)
  {
    animate('x', x);
    animate('y', y);
  }

  //-------------------------------------------------------------------------------------------------

  void fadeTo(num alpha)
  {
    animate('alpha', alpha);
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

          for(int i = 0; i < _animateProperties.length; i++)  {
            var ap = _animateProperties[i];

            switch(ap.name) {
              case 'x':        ap.startValue = _target.x; break;
              case 'y':        ap.startValue = _target.y; break;
              case 'pivotX':   ap.startValue = _target.pivotX; break;
              case 'pivotY':   ap.startValue = _target.pivotY; break;
              case 'scaleX':   ap.startValue = _target.scaleX; break;
              case 'scaleY':   ap.startValue = _target.scaleY; break;
              case 'rotation': ap.startValue = _target.rotation; break;
              case 'alpha':    ap.startValue = _target.alpha; break;
            }
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
          value = _roundToInt ? value.round() : value;

          switch(ap.name) {
            case 'x':        _target.x = value; break;
            case 'y':        _target.y = value; break;
            case 'pivotX':   _target.pivotX = value; break;
            case 'pivotY':   _target.pivotY = value; break;
            case 'scaleX':   _target.scaleX = value; break;
            case 'scaleY':   _target.scaleY = value; break;
            case 'rotation': _target.rotation = value; break;
            case 'alpha':    _target.alpha = value; break;
          }
        }

        for(int i = 0; i < _animateValues.length; i++) {
          var av = _animateValues[i];
          var value = av.startValue + transition * (av.targetValue - av.startValue);
          value = _roundToInt ? value.round() : value;

          av.tweenFunction(value);
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

  Dynamic get target => _target;
  num get totalTime => _totalTime;
  num get currentTime => _currentTime;
  num get delay => _delay;
  bool get roundToInt => _roundToInt;
  bool get isComplete => _currentTime >= _totalTime;

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

  Function get onStart => _onStart;
  Function get onUpdate => _onUpdate;
  Function get onComplete => _onComplete;

  void set onStart(Function value) { _onStart = value; }
  void set onUpdate(Function value) { _onUpdate = value; }
  void set onComplete(Function value) { _onComplete = value; }

}
