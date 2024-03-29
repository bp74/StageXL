part of '../animation.dart';

/// The [TransitionFunction] is the function signature for transitions used
/// in the [Tween] and [Translation] classes. The function takes the ratio
/// between 0.0 and 1.0 and returns the actual progress of the transition.
///
/// See also: [Transition], [Tween], [Translation]
///
/// Examples:
///
///     // a linear transition
///     TransitionFunction transition = (ratio) => ratio;
///
///     // a quadratic transition
///     TransitionFunction transition = (ratio) => ratio * ratio;

typedef TransitionFunction = num Function(num ratio);

/// The [Transition] class provides common transition functions
/// used by the [Tween] and [Translation] classes.
///
/// Overview of all available transition functions:
/// <http://www.stagexl.org/docs/transitions.html>

class Transition {
  // Standard

  static final Random _random = Random();

  static num linear(num ratio) => ratio;

  static num sine(num ratio) => 0.5 - 0.5 * cos(ratio * 2.0 * pi);

  static num cosine(num ratio) => 0.5 + 0.5 * cos(ratio * 2.0 * pi);

  static num random(num ratio) {
    if (ratio == 0.0 || ratio == 1.0) return ratio;
    return _random.nextDouble();
  }

  static TransitionFunction custom(num amount) {
    if (amount < -1) amount = -1;
    if (amount > 1) amount = 1;

    num easing(num t) {
      if (amount == 0) return t;
      if (amount < 0) return t * (t * -amount + 1 + amount);
      return t * ((2 - t) * amount + (1 - amount));
    }

    return easing;
  }

  // Quadratic

  static num easeInQuadratic(num ratio) => ratio * ratio;

  static num easeOutQuadratic(num ratio) {
    ratio = 1.0 - ratio;
    return 1.0 - ratio * ratio;
  }

  static num easeInOutQuadratic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInQuadratic(ratio)
        : 0.5 * easeOutQuadratic(ratio - 1.0) + 0.5;
  }

  static num easeOutInQuadratic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutQuadratic(ratio)
        : 0.5 * easeInQuadratic(ratio - 1.0) + 0.5;
  }

  // Cubic

  static num easeInCubic(num ratio) => ratio * ratio * ratio;

  static num easeOutCubic(num ratio) {
    ratio = 1.0 - ratio;
    return 1.0 - ratio * ratio * ratio;
  }

  static num easeInOutCubic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInCubic(ratio)
        : 0.5 * easeOutCubic(ratio - 1.0) + 0.5;
  }

  static num easeOutInCubic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutCubic(ratio)
        : 0.5 * easeInCubic(ratio - 1.0) + 0.5;
  }

  // Quartic

  static num easeInQuartic(num ratio) => ratio * ratio * ratio * ratio;

  static num easeOutQuartic(num ratio) {
    ratio = 1.0 - ratio;
    return 1.0 - ratio * ratio * ratio * ratio;
  }

  static num easeInOutQuartic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInQuartic(ratio)
        : 0.5 * easeOutQuartic(ratio - 1.0) + 0.5;
  }

  static num easeOutInQuartic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutQuartic(ratio)
        : 0.5 * easeInQuartic(ratio - 1.0) + 0.5;
  }

  // Quintic

  static num easeInQuintic(num ratio) => ratio * ratio * ratio * ratio * ratio;

  static num easeOutQuintic(num ratio) {
    ratio = 1.0 - ratio;
    return 1.0 - ratio * ratio * ratio * ratio * ratio;
  }

  static num easeInOutQuintic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInQuintic(ratio)
        : 0.5 * easeOutQuintic(ratio - 1.0) + 0.5;
  }

  static num easeOutInQuintic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutQuintic(ratio)
        : 0.5 * easeInQuintic(ratio - 1.0) + 0.5;
  }

  // Circular

  static num easeInCircular(num ratio) => 1.0 - sqrt(1.0 - ratio * ratio);

  static num easeOutCircular(num ratio) {
    ratio = 1.0 - ratio;
    return sqrt(1.0 - ratio * ratio);
  }

  static num easeInOutCircular(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInCircular(ratio)
        : 0.5 * easeOutCircular(ratio - 1.0) + 0.5;
  }

  static num easeOutInCircular(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutCircular(ratio)
        : 0.5 * easeInCircular(ratio - 1.0) + 0.5;
  }

  // Sine

  static num easeInSine(num ratio) => 1.0 - cos(ratio * (pi / 2.0));

  static num easeOutSine(num ratio) => sin(ratio * (pi / 2.0));

  static num easeInOutSine(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInSine(ratio)
        : 0.5 * easeOutSine(ratio - 1.0) + 0.5;
  }

  static num easeOutInSine(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutSine(ratio)
        : 0.5 * easeInSine(ratio - 1.0) + 0.5;
  }

  // Exponential

  static num easeInExponential(num ratio) {
    if (ratio == 0.0) return 0.0;
    return pow(2.0, 10.0 * (ratio - 1.0));
  }

  static num easeOutExponential(num ratio) {
    if (ratio == 1.0) return 1.0;
    return 1.0 - pow(2.0, -10.0 * ratio);
  }

  static num easeInOutExponential(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInExponential(ratio)
        : 0.5 * easeOutExponential(ratio - 1.0) + 0.5;
  }

  static num easeOutInExponential(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutExponential(ratio)
        : 0.5 * easeInExponential(ratio - 1.0) + 0.5;
  }

  // Back

  static num easeInBack(num ratio) {
    const num s = 1.70158;
    return ratio * ratio * ((s + 1.0) * ratio - s);
  }

  static num easeOutBack(num ratio) {
    const num s = 1.70158;
    ratio = ratio - 1.0;
    return ratio * ratio * ((s + 1.0) * ratio + s) + 1.0;
  }

  static num easeInOutBack(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInBack(ratio)
        : 0.5 * easeOutBack(ratio - 1.0) + 0.5;
  }

  static num easeOutInBack(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutBack(ratio)
        : 0.5 * easeInBack(ratio - 1.0) + 0.5;
  }

  // Elastic

  static num easeInElastic(num ratio) {
    if (ratio == 0.0 || ratio == 1.0) return ratio;
    ratio = ratio - 1.0;
    return -pow(2.0, 10.0 * ratio) *
        sin((ratio - 0.3 / 4.0) * (2.0 * pi) / 0.3);
  }

  static num easeOutElastic(num ratio) {
    if (ratio == 0.0 || ratio == 1.0) return ratio;
    return pow(2.0, -10.0 * ratio) *
            sin((ratio - 0.3 / 4.0) * (2.0 * pi) / 0.3) +
        1;
  }

  static num easeInOutElastic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInElastic(ratio)
        : 0.5 * easeOutElastic(ratio - 1.0) + 0.5;
  }

  static num easeOutInElastic(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutElastic(ratio)
        : 0.5 * easeInElastic(ratio - 1.0) + 0.5;
  }

  // Bounce

  static num easeInBounce(num ratio) => 1.0 - easeOutBounce(1.0 - ratio);

  static num easeOutBounce(num ratio) {
    if (ratio < 1 / 2.75) {
      return 7.5625 * ratio * ratio;
    } else if (ratio < 2 / 2.75) {
      ratio = ratio - 1.5 / 2.75;
      return 7.5625 * ratio * ratio + 0.75;
    } else if (ratio < 2.5 / 2.75) {
      ratio = ratio - 2.25 / 2.75;
      return 7.5625 * ratio * ratio + 0.9375;
    } else {
      ratio = ratio - 2.625 / 2.75;
      return 7.5625 * ratio * ratio + 0.984375;
    }
  }

  static num easeInOutBounce(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeInBounce(ratio)
        : 0.5 * easeOutBounce(ratio - 1.0) + 0.5;
  }

  static num easeOutInBounce(num ratio) {
    ratio = ratio * 2.0;
    return (ratio < 1.0)
        ? 0.5 * easeOutBounce(ratio)
        : 0.5 * easeInBounce(ratio - 1.0) + 0.5;
  }
}
