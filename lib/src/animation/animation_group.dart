part of '../animation.dart';

/// The [AnimationGroup] class is used to animate multiple Animatables.
/// Those Animatables are animated in parallel and the onComplete
/// callback is called when all Animatables have completed.
///
/// See also: [Juggler], [AnimationGroup], [Animatable]
///
/// Examples:
///
///     var ag = new AnimationGroup();
///     ag.add(new Tween(sprite, 2.0, Transition.easeOutBounce)..animate.x.to(700));
///     ag.add(new Tween(sprite, 2.0, Transition.linear)..animate.y.to(500));
///     ag.delay = 1.0;
///     ag.onStart = () => print("start");
///     ag.onComplete = () => print("complete");
///     juggler.add(ag);
///
///     juggler.addGroup([
///        new Tween(sprite, 2.0, Transition.easeOutBounce)..animate.x.to(700),
///        new Tween(sprite, 2.0, Transition.linear)..animate.y.to(500)])
///        ..onComplete = () => print("complete");
///
class AnimationGroup implements Animatable {
  final List<Animatable> _animatables = <Animatable>[];

  void Function()? _onStart;
  void Function()? _onComplete;

  final Completer<void> completer = Completer<void>();

  num _time = 0.0;
  num _delay = 0.0;
  bool _started = false;
  bool _completed = false;

  //----------------------------------------------------------------------------

  /// Adds the [animatable] to this [AnimationGroup].
  void add(Animatable animatable) {
    _animatables.add(animatable);
  }

  @override
  bool advanceTime(num time) {
    _time += time;

    if (_started == false) {
      if (_time > _delay) {
        _started = true;
        if (_onStart != null) _onStart!();
      } else {
        return true;
      }
    }

    for (var i = 0; i < _animatables.length;) {
      if (_animatables[i].advanceTime(time) == false) {
        _animatables.removeAt(i);
      } else {
        i++;
      }
    }

    if (_animatables.isEmpty) {
      _completed = true;
      if (!completer.isCompleted) {
        completer.complete();
      }
      if (_onComplete != null) _onComplete!();
      return false;
    } else {
      return true;
    }
  }

  //----------------------------------------------------------------------------

  /// The delay this [AnimatableGroup] waits until it starts animating.
  ///
  /// The delay may be changed as long as the animation has not been started.
  num get delay => _delay;

  set delay(num value) {
    if (_started == false) {
      _time = _time + _delay - value;
      _delay = value;
    }
  }

  /// Indicates if this [AnimatableGroup] is completed.
  bool get isComplete => _completed;

  ///Future for when the tween is completed
  Future completed() => completer.future;

  //----------------------------------------------------------------------------

  /// The function that is called when an [AnimationGroup] starts.
  ///
  /// This happens after the specified [delay].
  set onStart(void Function() function) {
    _onStart = function;
  }

  /// The function that is called when a [AnimationGroup] is completed.
  set onComplete(void Function() function) {
    _onComplete = function;
  }
}
