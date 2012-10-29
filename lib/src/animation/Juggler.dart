part of dartflash;

class Juggler implements Animatable
{
  List<Animatable> _animatables;
  int _animatablesCount;
  num _elapsedTime;

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

    if (_animatablesCount >= _animatables.length)
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

    for(int i = 0; i < _animatablesCount; i++)
      if (_animatables[i] == animatable)
        _animatables[i] = null;
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
    int c = 0;

    for(int i = 0; i < animatablesCount; i++)
    {
      Animatable animatable = _animatables[i];

      if (animatable != null && animatable.advanceTime(time))
      {
        if (c != i) _animatables[c] = animatable;
        c++;
      }
    }

    //-----------------------------------------------------------------------
    // 3) move newly added animatables to the left and clear rest

    for(int i = animatablesCount; i < _animatablesCount; i++)
      _animatables[c++] = _animatables[i];

    for(int i = c; i < _animatablesCount; i++)
      _animatables[i] = null;

    _animatablesCount = c;

    return true;
  }

}
