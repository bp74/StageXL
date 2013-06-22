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
      var link = _firstAnimatableLink;
      while(identical(link, _lastAnimatableLink) == false) {
        if (identical(link.animatable, animatable)) {
          link.animatable = null;
          break;
        }
        link = link.nextAnimatableLink;
      }
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool contains(Animatable animatable) {

    if (animatable != null) {
      var link = _firstAnimatableLink;
      while(identical(link, _lastAnimatableLink) == false) {
        if (identical(link.animatable, animatable)) return true;
        link = link.nextAnimatableLink;
      }
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void removeTweens(DisplayObject displayObject) {

    var link = _firstAnimatableLink;
    while(identical(link, _lastAnimatableLink) == false) {
      var animatable = link.animatable;
      if (animatable is Tween && identical(animatable.displayObject, displayObject)) {
        link.animatable = null;
      }
      link = link.nextAnimatableLink;
    }
  }

  //-----------------------------------------------------------------------------------------------

  bool containsTweens(DisplayObject displayObject) {

    var link = _firstAnimatableLink;
    while(identical(link, _lastAnimatableLink) == false) {
      var animatable = link.animatable;
      if (animatable is Tween && identical(animatable.displayObject, displayObject)) {
        return true;
      }
      link = link.nextAnimatableLink;
    }

    return false;
  }

  //-----------------------------------------------------------------------------------------------

  void purge() {

    var link = _firstAnimatableLink;
    while(identical(link, _lastAnimatableLink) == false) {
      link.animatable = null;
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

    var link = _firstAnimatableLink;
    var lastLink = _lastAnimatableLink;

    while(identical(link, lastLink) == false) {

      var animatable = link.animatable;
      if (animatable == null) {

        var nextLink = link.nextAnimatableLink;
        link.animatable = nextLink.animatable;
        link.nextAnimatableLink = nextLink.nextAnimatableLink;

        if (identical(nextLink, lastLink)) lastLink = link;
        if (identical(nextLink, _lastAnimatableLink)) _lastAnimatableLink = link;

      } else if (animatable.advanceTime(time) == false) {
        link.animatable = null;
      } else {
        link = link.nextAnimatableLink;
      }
    }

    return true;
  }

}
