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
///     var tween = new Tween(sprite, 1.0, Transition.easeIn);
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
  final _elapsedTimeChangedEvent = new StreamController<num>.broadcast();

  Juggler() {
    _firstAnimatableLink = new _AnimatableLink();
    _lastAnimatableLink = _firstAnimatableLink;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// The elapsed time since the juggler has started.

  num get elapsedTime => _elapsedTime;

  /// A stream of [elapsedTime] changes.
  ///
  /// The stream sends the changes of [elapsedTime] and is executed before all
  /// other animatables are processed.
  ///
  ///     await for (var elapsedTime in juggler.onElapsedTimeChange) {
  ///        print(elapsedTime);
  ///     }

  Stream<num> get onElapsedTimeChange => _elapsedTimeChangedEvent.stream;

  /// Returns a Future which completes after [time] seconds.
  ///
  /// This method is based on the [onElapsedTimeChange] stream and
  /// is therefore executed before all other animatables.
  ///
  ///     await juggler.delay(1.0);

  Future delay(num time) async {
    var nextTime = this.elapsedTime + time;
    await for(var elapsedTime in this.onElapsedTimeChange) {
      if (elapsedTime >= nextTime) break;
    }
  }

  /// Returns a Stream of counter values which fires every [time] seconds.
  ///
  /// The stream returns a counter with the number of completed intervals.
  /// The stream ends automatically after [time] seconds.
  ///
  /// This method is based on the [onElapsedTimeChange] stream and
  /// is therefore executed before all other animatables.
  ///
  ///     await for (var counter in juggler.interval(0.5)) {
  ///       print(counter);
  ///     }
  ///
  ///     var stream = juggler.interval(0.5).take(10);
  ///     stream.listen((counter) => print(counter));

  Stream<int> interval(num time) async* {
    var count = 0;
    var nextTime = this.elapsedTime + time;
    await for(var elapsedTime in this.onElapsedTimeChange) {
      while (elapsedTime >= nextTime) {
        yield ++count;
        nextTime = nextTime + time;
      }
    }
  }

  /// Returns a Stream of relative time which fires for [time] seconds.
  ///
  /// The stream returns the relative time since the start of the method.
  /// The stream ends automatically after [time] seconds.
  ///
  /// This method is based on the [onElapsedTimeChange] stream and
  /// is therefore executed before all other animatables.
  ///
  ///     await for (var time in juggler.timespan(2.0)) {
  ///       print(time);
  ///     }
  ///
  ///     var stream = juggler.timespan(2.0).map((time) => 2.0 * time);
  ///     stream.listen((value) => print(value));

  Stream<num> timespan(num time) async* {
    var startTime = this.elapsedTime;
    await for(var elapsedTime in this.onElapsedTimeChange) {
      var currentTime = elapsedTime - startTime;
      var clampedTime = currentTime < time ? currentTime : time;
      yield clampedTime;
      if (currentTime >= time) break;
    }
  }

  /// Returns a Stream of translated values which fires for [time] seconds.
  ///
  /// The stream returns the translated values based on the [transition] and
  /// the time elapsed since the start of the method. The stream ends
  /// automatically after [time] seconds.
  ///
  /// This method is based on the [onElapsedTimeChange] stream and
  /// is therefore executed before all other animatables.
  ///
  ///     var transition = Transition.easeInSine;
  ///     await for (var value in juggler.translation(0.0, 10.0, 5.0, transition)) {
  ///       print(value);
  ///     }

  Stream<num> translation(num startValue, num targetValue, num time, [
      TransitionFunction transition = Transition.linear]) async* {

    var startTime = this.elapsedTime;
    var deltaValue = targetValue - startValue;
    await for(var elapsedTime in this.onElapsedTimeChange) {
      var currentTime = elapsedTime - startTime;
      var clampedTime = currentTime < time ? currentTime : time;
      yield startValue + deltaValue * transition(clampedTime / time);
      if (currentTime >= time) break;
    }
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// Adds the [animatable] to this juggler who will take care that it is
  /// animated.
  ///
  /// When the animatable is finished it is automatically removed from this
  /// juggler. An animatable is finished as soon as it's advanceTime method
  /// returns false.

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

  /// Returns true if this juggler contains tweens for the specified
  /// [tweenObject].

  bool containsTweens(TweenObject tweenObject) {

    var link = _firstAnimatableLink;
    while (identical(link, _lastAnimatableLink) == false) {
      var animatable = link.animatable;
      if (animatable is Tween && identical(animatable.tweenObject, tweenObject)) {
        return true;
      }
      link = link.nextAnimatableLink;
    }

    return false;
  }

  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  /// This is a convenience method that creates a [DelayedCall] and adds it to
  /// this juggler. See [DelayedCall] for more details.
  ///
  /// Example:
  ///
  ///     // Delay the call of action by 5.0 seconds.
  ///     juggler.delayCall(action, 5.0);

  DelayedCall delayCall(Function action, num delay) {
    DelayedCall delayedCall = new DelayedCall(action, delay);
    add(delayedCall);
    return delayedCall;
  }

  /// This is a convenience method that creates a [Tween] and adds it to
  /// this juggler. See [Tween] for more details.
  ///
  /// Example:
  ///
  ///     // Animate the x and y properties of the spaceship.
  ///     var tween = juggler.addTween(spaceship, 2.0, Transition.linear);
  ///     tween.animate.x.to(100);
  ///     tween.animate.y.to(200);

  Tween addTween(TweenObject tweenObject, num time, [
                 TransitionFunction transition = Transition.linear]) {

    Tween tween = new Tween(tweenObject, time, transition);
    add(tween);
    return tween;
  }

  /// This is a convenience method that creates a [Translation] and adds it to
  /// this juggler. See [Translation] for more details.
  ///
  /// Example:
  ///
  ///     // Animate the value from 0.0 to 100.0 within 5.0 seconds.
  ///     var transition = Transition.linear;
  ///     juggler.addTranslation(0.0, 100.0, 5.0, transition, (num value) {
  ///       print(value);
  ///     });

  Translation addTranslation(num startValue, num targetValue, num time,
                             TransitionFunction transition, void onUpdate(num value)) {

    var translation = new Translation(startValue, targetValue, time, transition);
    translation.onUpdate = onUpdate;
    add(translation);
    return translation;
  }

  /// This is a convenience method that creates an [AnimatableGroup] and adds
  /// it to this juggler. See [AnimatableGroup] for more details.
  ///
  /// Example:
  ///
  ///     // Animate two tweens in parallel and report when complete.
  ///     var tween1 = new Tween(sprite, 3.0)..animate.x.to(700);
  ///     var tween2 = new Tween(sprite, 2.0)..animate.y.to(500)
  ///     var animationGroup = juggler.addGroup([tween1, tween2]);
  ///     animationGroup.onComplete = () => print("complete");

  AnimationGroup addGroup(List<Animatable> animatables) {
    var animationGroup = new AnimationGroup();
    for (int i = 0; i < animatables.length; i++) {
      animationGroup.add(animatables[i]);
    }
    add(animationGroup);
    return animationGroup;
  }

  /// This is a convenience method that creates an [AnimatableChain] and adds
  /// it to this juggler. See [AnimatableChain] for more details.
  ///
  /// Example:
  ///
  ///     // Animate two tweens sequentially and report when complete.
  ///     var tween1 = new Tween(sprite, 3.0)..animate.x.to(700);
  ///     var tween2 = new Tween(sprite, 2.0)..animate.y.to(500);
  ///     var animationChain = juggler.addChain([tween1, tween2]);
  ///     animationChain.onComplete = () => print("complete");

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
    _elapsedTimeChangedEvent.add(_elapsedTime);

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
