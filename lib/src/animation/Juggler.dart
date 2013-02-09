part of dartflash;

class Juggler implements Animatable
{
  num _elapsedTime;
  
  List<Animatable> _animatables;
  int _animatablesCount;

  Juggler() 
  {
    _elapsedTime = 0.0;

    _animatables = new List<Animatable>();
    _animatablesCount = 0;
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  num get elapsedTime => _elapsedTime;

  //-------------------------------------------------------------------------------------------------

  void add(Animatable animatable)
  {
    if (animatable == null)
      return;

    if (_animatablesCount == _animatables.length)
      _animatables.add(animatable);
    else
      _animatables[_animatablesCount] = animatable;

    _animatablesCount++;
  }

  //-------------------------------------------------------------------------------------------------

  void remove(Animatable animatable)
  {
    if (animatable == null)
      return;

    for(int i = 0; i < _animatablesCount; i++) {
      if (_animatables[i] == animatable) {
        _animatables[i] = null;
        break;
      }
    }
  }

  //-------------------------------------------------------------------------------------------------

  void removeTweens(DisplayObject displayObject)
  {
    if (displayObject == null)
      return;

    for(int i = 0; i < _animatablesCount; i++)
    {
      var animatable = _animatables[i];

      if (animatable != null && animatable is Tween)
        if (animatable.displayObject == displayObject)
          _animatables[i] = null;
    }
  }

  //-------------------------------------------------------------------------------------------------

  void purge()
  {
    for(int i = 0; i < _animatablesCount; i++)
      _animatables[i] = null;

    _animatablesCount = 0;
  }

  //-------------------------------------------------------------------------------------------------

  DelayedCall delayCall(Function action, num delay)
  {
    DelayedCall delayedCall = new DelayedCall(action, delay);
    add(delayedCall);

    return delayedCall;
  }

  //-------------------------------------------------------------------------------------------------

  Transition startTransition(num startValue, num targetValue, num time, num transitionFunction(num ratio), void onUpdate(num value))
  {
    Transition transition = new Transition(startValue, targetValue, time, transitionFunction);
    transition.onUpdate = onUpdate;
    add(transition);

    return transition;
  }

  //-------------------------------------------------------------------------------------------------

  bool advanceTime(num time)
  {
    _elapsedTime += time;

    // There is a high probability that the "advanceTime" function adds new animatables to
    // the Juggler, but we don't want to process those animatables in the current frame.
    // The new animatables should be processed in the next frame!

    //-----------------------------------------------------------------------
    // 1) process all animatables from start to current "_animatablesCount".
    // 2) remove completed animatables or null values from the list.

    int animatablesCount = _animatablesCount;
    int tail = 0;

    for(int head = 0; head < animatablesCount; head++) {
      Animatable animatable = _animatables[head];

      if (animatable != null && animatable.advanceTime(time)) {
        if (tail != head) _animatables[tail] = animatable;
        tail++;
      }
    }

    //-----------------------------------------------------------------------
    // 3) move newly added animatables to the left and clear rest

    for(int i = animatablesCount; i < _animatablesCount; i++)
      _animatables[tail++] = _animatables[i];

    for(int i = tail; i < _animatablesCount; i++)
      _animatables[i] = null;

    _animatablesCount = tail;

    return true;
  }

}
