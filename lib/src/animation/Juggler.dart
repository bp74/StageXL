part of stagexl;

class _AnimatableLink {
  Animatable animatable;
  _AnimatableLink nextAnimatableLink;
}

class Juggler implements Animatable {

  _AnimatableLink _firstAnimatableLink;
  _AnimatableLink _lastAnimatableLink;

  num _elapsedTime = 0.0;

  Juggler() {
    _firstAnimatableLink = new _AnimatableLink();
    _lastAnimatableLink = _firstAnimatableLink;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  num get elapsedTime => _elapsedTime;

  //-----------------------------------------------------------------------------------------------

  void add(Animatable animatable) {

    if (animatable is! Animatable) {
      throw new ArgumentError("The supplied animatable does not extend type Animatable.");
    }

    if (this.contains(animatable) == false) {
      var animatableLink = new _AnimatableLink();
      _lastAnimatableLink.animatable = animatable;
      _lastAnimatableLink.nextAnimatableLink = animatableLink;
      _lastAnimatableLink = animatableLink;
    }
  }

  //-----------------------------------------------------------------------------------------------

  void remove(Animatable animatable) {

    if (animatable != null) {
      var animatableLink = _firstAnimatableLink;
      while(identical(animatableLink, _lastAnimatableLink) == false) {
        if (identical(animatableLink.animatable, animatable)) {
          animatableLink.animatable = null;
          break;
        }
        animatableLink = animatableLink.nextAnimatableLink;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(Animatable animatable) {

    if (animatable != null) {
      var animatableLink = _firstAnimatableLink;
      while(identical(animatableLink, _lastAnimatableLink) == false) {
        if (identical(animatableLink.animatable, animatable)) {
          return true;
        }
        animatableLink = animatableLink.nextAnimatableLink;
      }
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void removeTweens(DisplayObject displayObject) {

    var animatableLink = _firstAnimatableLink;
    while(identical(animatableLink, _lastAnimatableLink) == false) {
      var animatable = animatableLink.animatable;
      if (animatable is Tween && identical(animatable.displayObject, displayObject)) {
        animatableLink.animatable = null;
      }
      animatableLink = animatableLink.nextAnimatableLink;
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool containsTweens(DisplayObject displayObject) {

    var animatableLink = _firstAnimatableLink;
    while(identical(animatableLink, _lastAnimatableLink) == false) {
      var animatable = animatableLink.animatable;
      if (animatable is Tween && identical(animatable.displayObject, displayObject)) {
        return true;
      }
      animatableLink = animatableLink.nextAnimatableLink;
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void purge() {

    var animatableLink = _firstAnimatableLink;
    while(identical(animatableLink, _lastAnimatableLink) == false) {
      animatableLink.animatable = null;
    }

    _lastAnimatableLink = _firstAnimatableLink;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  Tween tween(DisplayObject displayObject, num time, [EaseFunction transitionFunction]) {

    Tween tween = transitionFunction != null
        ? new Tween(displayObject, time, transitionFunction)
        : new Tween(displayObject, time);

    add(tween);
    return tween;
  }

  //-----------------------------------------------------------------------------------------------

  Transition transition(num startValue, num targetValue, num time, EaseFunction transitionFunction, void onUpdate(num value)) {

    Transition transition = new Transition(startValue, targetValue, time, transitionFunction);
    transition.onUpdate = onUpdate;
    add(transition);

    return transition;
  }

  //-----------------------------------------------------------------------------------------------

  DelayedCall delayCall(Function action, num delay) {

    DelayedCall delayedCall = new DelayedCall(action, delay);
    add(delayedCall);

    return delayedCall;
  }

  //-----------------------------------------------------------------------------------------------
  //-----------------------------------------------------------------------------------------------

  bool advanceTime(num time) {

    _elapsedTime += time;

    // Call advanceTime of current animatables.
    // Do not call advanceTime of newly added animatables.

    var animatableLink = _firstAnimatableLink;
    var lastAnimatableLink = _lastAnimatableLink;

    while(identical(animatableLink, lastAnimatableLink) == false) {

      var animatable = animatableLink.animatable;
      if (animatable == null) {
        var nextAnimatableLink = animatableLink.nextAnimatableLink;
        animatableLink.animatable = nextAnimatableLink.animatable;
        animatableLink.nextAnimatableLink = nextAnimatableLink.nextAnimatableLink;

        if (identical(nextAnimatableLink, lastAnimatableLink)) {
          lastAnimatableLink = animatableLink;
          if (identical(nextAnimatableLink, _lastAnimatableLink)) {
            _lastAnimatableLink = animatableLink;
          }
        }
      } else if (animatable.advanceTime(time) == false) {
        animatableLink.animatable = null;
      } else {
        animatableLink = animatableLink.nextAnimatableLink;
      }
    }

    return true;
  }

}
