part of stagexl.animation;

class _AnimatableLink {
  Animatable animatable;
  _AnimatableLink nextAnimatableLink;
}

/// The [Juggler] controls the progress of your application by
/// propagating the time passed between two render frames.
///
/// The RenderLoop and Stage class provide juggler instances which are
/// driven by the browsers animation frames. You can also create your
/// own Juggler instance and control the time by yourself.
/// Because [Juggler] implements the [Animatable] interface it can be
/// added to other Juggler instances too.
///
/// See also: [Tween], [Transition], [DelayedCall]
///
/// Examples:
///
///     var tween = new Tween(sprite, 1.0, TransitionFunction.easeIn);
///     tween.animate.x.to(1.0);
///     stage.juggler.add(tween);
///
///     // create a "gameJuggler" who controls all my animations.
///     var gameJuggler = new Juggler();
///     // start all animations controlled by "gameJuggler".
///     stage.juggler.add(gameJuggler);
///     // stop all animations controlled by "gameJuggler".
///     stage.juggler.remove(gameJuggler);

class Juggler implements Animatable {

  _AnimatableLink _firstAnimatableLink;
  _AnimatableLink _lastAnimatableLink;

  num _elapsedTime = 0.0;

  Juggler() {
    _firstAnimatableLink = new _AnimatableLink();
    _lastAnimatableLink = _firstAnimatableLink;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// The total elapsed time.

  num get elapsedTime => _elapsedTime;

  //----------------------------------------------------------------------------

  /// Adds the [animatable] to this juggler who will take care that it is
  /// animated.
  ///
  /// When the animatable is finished it is automatically removed from this
  /// juggler.

  void add(Animatable animatable) {
    if (animatable is! Animatable) {
      throw new ArgumentError(
          "The supplied animatable does not extend type Animatable.");
    }

    if (this.contains(animatable) == false) {
      var animatableLink = new _AnimatableLink();
      _lastAnimatableLink.animatable = animatable;
      _lastAnimatableLink.nextAnimatableLink = animatableLink;
      _lastAnimatableLink = animatableLink;
    }
  }

  //----------------------------------------------------------------------------

  /// Removes the specified [animatable] from this juggler.

  void remove(Animatable animatable) {
    if (animatable != null) {
      var link = _firstAnimatableLink;
      while (identical(link, _lastAnimatableLink) == false) {
        if (identical(link.animatable, animatable)) {
          link.animatable = null;
          break;
        }
        link = link.nextAnimatableLink;
      }
    }
  }

  //----------------------------------------------------------------------------

  /// Returns true if this juggler contains the specified [animatable].

  bool contains(Animatable animatable) {

    if (animatable != null) {
      var link = _firstAnimatableLink;
      while (identical(link, _lastAnimatableLink) == false) {
        if (identical(link.animatable, animatable)) return true;
        link = link.nextAnimatableLink;
      }
    }

    return false;
  }

  //----------------------------------------------------------------------------

  /// Removes all tweens from the specified [tweenObject].

  void removeTweens(TweenObject tweenObject) {

    var link = _firstAnimatableLink;
    while (identical(link, _lastAnimatableLink) == false) {
      var animatable = link.animatable;
      if (animatable is Tween && identical(animatable.tweenObject, tweenObject)) {
        link.animatable = null;
      }
      link = link.nextAnimatableLink;
    }
  }

  //----------------------------------------------------------------------------

  /// Returns true if this juggler contains tweens for the specified
  /// [tweenObject].

  bool containsTweens(TweenObject tweenObject) {

    var link = _firstAnimatableLink;
    while(identical(link, _lastAnimatableLink) == false) {
      var animatable = link.animatable;
      if (animatable is Tween && identical(animatable.tweenObject, tweenObject)) {
        return true;
      }
      link = link.nextAnimatableLink;
    }

    return false;
  }

  //----------------------------------------------------------------------------

  /// Removes all [Animatable]s from this juggler.
  void clear() {
    var link = _firstAnimatableLink;
    while (identical(link, _lastAnimatableLink) == false) {
      link.animatable = null;
      link = link.nextAnimatableLink;
    }

    _lastAnimatableLink = _firstAnimatableLink;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Animates properties of the [tweenObject].
  ///
  /// This is a convenience method that creates a [Tween] and adds it to this
  /// juggler. See [Tween] for more details.
  ///
  /// Example:
  ///
  ///     // Create a tween and animate the x and y property of the spaceship
  ///     juggler.tween(spaceship, 2.0, TransitionFunction.linear)
  ///       ..animate.x.to(100)
  ///       ..animate.y.to(200);

  Tween tween(TweenObject tweenObject, num time, [EaseFunction transitionFunction]) {

    Tween tween = transitionFunction != null
        ? new Tween(tweenObject, time, transitionFunction)
        : new Tween(tweenObject, time);

    add(tween);
    return tween;
  }

  //----------------------------------------------------------------------------

  /// Animates a value by calling the [onUpdate] function continuously.
  ///
  /// This is a convenience method that creates a [Transition] and adds it to
  /// this juggler. See [Transition] for more details.
  ///
  /// Example:
  ///
  ///     // Create a transition for a value from 0.0 to 100.0 within 5.0 seconds.
  ///     juggler.transition(0.0, 100.0, 5.0, TransitionFunction.linear, (num value) => print(value));

  Transition transition(num startValue, num targetValue, num time,
      EaseFunction transitionFunction, void onUpdate(num value)) {
    Transition transition =
        new Transition(startValue, targetValue, time, transitionFunction);
    transition.onUpdate = onUpdate;
    add(transition);

    return transition;
  }

  //----------------------------------------------------------------------------

  /// Delays the invocation of the [action] function by the given [delay] in
  /// seconds.
  ///
  /// This is a convenience method that creates a [DelayedCall] and adds it to
  /// this juggler. See [DelayedCall] for more details.
  ///
  /// Example:
  ///
  ///     // Delay the call of 'action' by 5.0 seconds.
  ///     juggler.delayCall(action, 5.0);

  DelayedCall delayCall(Function action, num delay) {
    DelayedCall delayedCall = new DelayedCall(action, delay);
    add(delayedCall);
    return delayedCall;
  }

  //----------------------------------------------------------------------------

  /// Groups the specified list of [animatables] and runs them in parallel.
  ///
  /// This is a convenience method that creates an [AnimatableGroup] and adds
  /// it to this juggler. See [AnimatableGroup] for more details.
  ///
  /// Example:
  ///
  ///     // Group a list of Animatables (run them in parallel).
  ///     juggler.addGroup([
  ///         new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700),
  ///         new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500)])
  ///       ..onComplete = () => print("complete");

  AnimationGroup addGroup(List<Animatable> animatables) {
    var animationGroup = new AnimationGroup();
    for (int i = 0; i < animatables.length; i++) {
      animationGroup.add(animatables[i]);
    }
    add(animationGroup);
    return animationGroup;
  }

  //----------------------------------------------------------------------------

  /// Chains the specified list of [animatables] and runs them sequentially.
  ///
  /// This is a convenience method that creates an [AnimatableChain] and adds
  /// it to this juggler. See [AnimatableChain] for more details.
  ///
  /// Example:
  ///
  ///     // Chain a list of Animatables (run them sequentially).
  ///     juggler.addChain([
  ///         new Tween(sprite, 2.0, TransitionFunction.easeOutBounce)..animate.x.to(700),
  ///         new Tween(sprite, 2.0, TransitionFunction.linear)..animate.y.to(500)])
  ///       ..onComplete = () => print("complete");
  ///
  AnimationChain addChain(List<Animatable> animatables) {
    var animationChain = new AnimationChain();
    for (int i = 0; i < animatables.length; i++) {
      animationChain.add(animatables[i]);
    }
    add(animationChain);
    return animationChain;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  bool advanceTime(num time) {

    _elapsedTime += time;

    // Call advanceTime of current animatables.
    // Do not call advanceTime of newly added animatables.

    var link = _firstAnimatableLink;
    var lastLink = _lastAnimatableLink;

    while (identical(link, lastLink) == false) {
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
