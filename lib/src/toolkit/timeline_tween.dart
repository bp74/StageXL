part of stagexl.toolkit;

/*
* Ported from CreateJS to Dart
*
* Copyright (c) 2010 gskinner.com, inc.
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/

// ToDo: possibly add a END actionsMode (only runs actions that == position)?
// ToDo: evaluate a way to decouple paused from tick registration.

/// A TimelineTween instance tweens properties for a single target.
///
/// Instance methods can be chained for easy construction and sequencing:
///
/// Example:
///
///     target.alpha = 1;
///     TimelineTween.get(target)
///       .wait(500)
///       .to({alpha:0, visible:false}, 1000)
///       .call(() => print("complete"));
///
/// Multiple tweens can point to the same instance, however if they affect the
/// same properties there could be unexpected behaviour. To stop all tweens on
/// an object, use [TimelineTween.removeTweens] or pass `override:true` in the
/// [props] argument.
///
///     TimelineTween.get(target, {override:true}).to({x:100});
///
/// Subscribe to the "change" event to get notified when a property of the
/// target is changed.
///
///       TimelineTween.get(target, {override:true})
///         .to({x:100})
///         .addEventListener("change", (event) => print("change"));
///
/// See the [TimelineTween.get] method for additional param documentation.
///
class TimelineTween {
  /**
   * Constant defining the none actionsMode for use with setPosition.
   **/
  static const int NONE = 0;

  /**
   * Constant defining the loop actionsMode for use with setPosition.
   **/
  static const int LOOP = 1;

  /**
   * Constant defining the reverse actionsMode for use with setPosition.
   **/
  static const int REVERSE = 2;

  //static List<TimelineTween> _tweens = [];
  static EaseFunction _linearEase = TransitionFunction.linear;

  /**
   * Returns a new tween instance. This is functionally identical to using "new TimelineTween(...)", but looks cleaner
   * with the chained syntax of TweenJS.
   * @example
   *  var tween = TimelineTween.get(target);
   * @method get
   * @static
   * @param {Object} target The target object that will have its properties tweened.
   * @param {Object} [props] The configuration properties to apply to this tween instance (ex. <code>{loop:true, paused:true}</code>).
   * All properties default to false. Supported props are:<UL>
   *    <LI> loop: sets the loop property on this tween.</LI>
   *    <LI> ignoreGlobalPause: sets the ignoreGlobalPause property on this tween.</LI>
   *    <LI> override: if true, TimelineTween.removeTweens(target) will be called to remove any other tweens with the same target.
   *    <LI> paused: indicates whether to start the tween paused.</LI>
   *    <LI> position: indicates the initial position for this tween.</LI>
   *    <LI> onChange: specifies an onChange handler for this tween. Note that this is deprecated in favour of the
   *    "change" event.</LI>
   * </UL>
   * @param {Boolean} [override=false] If true, any previous tweens on the same target will be removed. This is the same as
   * calling <code>TimelineTween.removeTweens(target)</code>.
   * @return {TimelineTween} A reference to the created tween. Additional chained tweens, method calls, or callbacks can be
   * applied to the returned tween instance.
   **/
  static TimelineTween get(dynamic target, [Map<String, dynamic> props, bool override = false]) {
    //if (override) { TimelineTween.removeTweens(target); }
    return new TimelineTween(target, props);
  }

  /**
   * Advances all tweens. This typically uses the Ticker class (available in the EaselJS library), but you can call it
   * manually if you prefer to use your own "heartbeat" implementation.
   * @method tick
   * @static
   * @param {Number} delta The change in time in milliseconds since the last tick. Required unless all tweens have
   * <code>useTicks</code> set to true.
   * @param {Boolean} paused Indicates whether a global pause is in effect. Tweens with <code>ignoreGlobalPause</code> will ignore
   * this, but all others will pause if this is true.
  static void tickTweens(num delta, bool paused) {
   var tweens = _tweens; //TimelineTween._tweens.slice(); // to avoid race conditions.
   for(var i=0; i<tweens.length; i++) {
     var tween = tweens[i];
     if ((paused && !tween.ignoreGlobalPause) || tween._paused) { continue; }
     tween.tick(1);//tween._useTicks?1:delta);
   }
  }
   **/

  /**
   * Removes all existing tweens for a target. This is called automatically by new tweens if the <code>override</code> prop is true.
   * @method removeTweens
   * @static
   * @param {Object} target The target object to remove existing tweens from.
  static void removeTweens(target) {
   //if (!target.tweenjs_count) { return; }
   var tweens = TimelineTween._tweens;
   for(var i=tweens.length-1; i>=0; i--) {
     if (tweens[i]._target == target) {
       tweens[i]._paused = true;
       tweens.removeAt(i);
     }
   }
   //target.tweenjs_count = 0;
  }
   **/

  /**
   * Indicates whether there are any active tweens on the target object (if specified) or in general.
   * @method hasActiveTweens
   * @static
   * @param {Object} target Optional. If not specified, the return value will indicate if there are any active tweens
   * on any target.
   * @return {Boolean} A boolean indicating whether there are any active tweens.
  TimelineTween.hasActiveTweens(target) {
   if (target != null) {
     assert(target == null); // ToDo
     //return target.tweenjs_count;
   }
   return TimelineTween._tweens && TimelineTween._tweens.length;
  }
   **/

  /**
   * Registers or unregisters a tween with the ticking system.
   * @method _register
   * @static
   * @protected
  static void _register(TimelineTween tween, bool value) {
   var target = tween._target;
   if (value) {
     // ToDo: this approach might fail if a dev is using sealed objects in ES5
     //if (target) { target.tweenjs_count = target.tweenjs_count ? target.tweenjs_count+1 : 1; }
     TimelineTween._tweens.add(tween);
   }
   else {
     //if (target) { target.tweenjs_count--; }
     var i = TimelineTween._tweens.indexOf(tween);
     if (i != -1) { TimelineTween._tweens.removeAt(i); }
   }
  }
   **/

  /**
   * Causes this tween to continue playing when a global pause is active. For example, if TweenJS is using Ticker,
   * then setting this to true (the default) will cause this tween to be paused when <code>Ticker.setPaused(true)</code> is called.
   * See TimelineTween.tick() for more info. Can be set via the props param.
   **/
  bool ignoreGlobalPause = false;

  /**
   * If true, the tween will loop when it reaches the end. Can be set via the props param.
   **/
  bool loop = false;

  /**
   * Read-only. Specifies the total duration of this tween in ticks.
   * This value is automatically updated as you modify the tween. Changing it directly could result in unexpected
   * behaviour.
   **/
  num duration = 0;

  /**
   * Called whenever the tween's position changes with a single parameter referencing this tween instance.
   * @property onChange
   * @type {Function}
   **/
  ChangeHandler onChange = null;

  /**
   * Called whenever the tween's position changes with a single parameter referencing this tween instance.
   * @event change
   * @since 0.4.0
   void change = null;
   **/

  /**
   * Read-only. The target of this tween. This is the object on which the tweened properties will be changed. Changing
   * this property after the tween is created will not have any effect.
   * @property target
   * @type {Object}
   **/
  dynamic target = null;

  /**
   * Read-only. The current normalized position of the tween. This will always be a value between 0 and duration.
   * Changing this property directly will have no effect.
   **/
  num position = null;

// private properties:

  bool _paused = false;
  final Map<String, dynamic> _curQueueProps = {};
  final Map<String, dynamic> _initQueueProps = {};
  final List<TimelineStep> _steps = new List<TimelineStep>();
  final List<TimelineAction> _actions = new List<TimelineAction>();

  /**
   * Raw position.
   **/
  num _prevPosition = 0;

  /**
   * The position within the current step.
   */
  num _stepPosition = 0; // this is needed by MovieClip.

  /**
   * Normalized position.
   **/
  num _prevPos = -1;
  int _prevActionPos = -1;

  dynamic _target = null;

  /**
   * @method initialize
   * @param {Object} target
   * @param {Object} props
   * @protected
   **/
  TimelineTween(dynamic target, Map<String, dynamic> props) {
    target = _target = target;
    if (props != null) {
      ignoreGlobalPause = props.containsKey("ignoreGlobalPause") ? props["ignoreGlobalPause"] : false;
      loop = props.containsKey("loop") ? props["loop"] : false;
      onChange = props.containsKey("onChange") ? props["onChange"] : null;
      //if (props.containsKey("override") && props["override"] == true) { TimelineTween.removeTweens(target); }
    }

    if (props != null && props.containsKey("paused") && props["paused"] == true) {
      _paused = true;
    }
    //else { TimelineTween._register(this,true); }
    if (props != null && props.containsKey("position")) {
      setPosition(props["position"], TimelineTween.NONE);
    }
  }

  /**
   * Queues a wait (essentially an empty tween).
   * @example
   *  //This tween will wait 1s before alpha is faded to 0.
   *  createjs.TimelineTween.get(target).wait(1000).to({alpha:0}, 1000);
   * @method wait
   * @param {Number} duration The duration of the wait in milliseconds (or in ticks if <code>useTicks</code> is true).
   * @return {TimelineTween} This tween instance (for chaining calls).
   **/
  TimelineTween wait(num duration) {
    return w(duration);
  }
  TimelineTween w(num duration) {
    if (duration.isNaN || duration <= 0) {
      return this;
    }
    var o = _cloneProps(_curQueueProps);
    return _addStep(new TimelineStep(duration, o, _linearEase, o));
  }

  /**
   * Queues a tween from the current values to the target properties. Set duration to 0 to jump to these value.
   * Numeric properties will be tweened from their current value in the tween to the target value. Non-numeric
   * properties will be set at the end of the specified duration.
   * @example
   *  createjs.TimelineTween.get(target).to({alpha:0}, 1000);
   * @method to
   * @param {Object} props An object specifying property target values for this tween (Ex. <code>{x:300}</code> would tween the x
   *      property of the target to 300).
   * @param {Number} duration Optional. The duration of the wait in milliseconds (or in ticks if <code>useTicks</code> is true).
   *      Defaults to 0.
   * @param {Function} ease Optional. The easing function to use for this tween. Defaults to a linear ease.
   * @return {TimelineTween} This tween instance (for chaining calls).
   **/
  TimelineTween to(Map<String, dynamic> props, [num duration, EaseFunction ease]) {
    return t(props, duration, ease);
  }
  TimelineTween t(Map<String, dynamic> props, [num duration = 0, EaseFunction ease]) {
    num d = 0;
    if (duration != null && !duration.isNaN && duration > 0) d = duration;
    return _addStep(new TimelineStep(d, _cloneProps(_curQueueProps), ease, _cloneProps(_appendQueueProps(props))));
  }

  /**
   * Queues an action to call the specified function.
   *  @example
   *    //would call myFunction() after 1s.
   *    myTween.wait(1000).call(myFunction);
   * @method call
   * @param {Function} callback The function to call.
   * @param {Array} params Optional. The parameters to call the function with. If this is omitted, then the function
   *      will be called with a single param pointing to this tween.
   * @param {Object} scope Optional. The scope to call the function in. If omitted, it will be called in the target's
   *      scope.
   * @return {TimelineTween} This tween instance (for chaining calls).
   **/
  TimelineTween call(Function callback, [List<dynamic> params]) {
    return c(callback, params);
  }
  TimelineTween c(Function callback, [List<dynamic> params]) {
    return _addAction(new TimelineAction(callback, params != null ? params : [this]));
  }

  // ToDo: add clarification between this and a 0 duration .to:
  /**
   * Queues an action to set the specified props on the specified target. If target is null, it will use this tween's
   * target.
   * @example
   *  myTween.wait(1000).set({visible:false},foo);
   * @method set
   * @param {Object} props The properties to set (ex. <code>{visible:false}</code>).
   * @param {Object} target Optional. The target to set the properties on. If omitted, they will be set on the tween's target.
   * @return {TimelineTween} This tween instance (for chaining calls).
   **/
  TimelineTween set(Map<String, dynamic> props, [dynamic target]) {
    return s(props, target);
  }
  TimelineTween s(Map<String, dynamic> props, [dynamic target]) {
    return _addAction(new TimelineAction(_set, [props, target != null ? target : _target]));
  }

  /**
   * Queues an action to to play (unpause) the specified tween. This enables you to sequence multiple tweens.
   * @example
   *  myTween.to({x:100},500).play(otherTween);
   * @method play
   * @param {TimelineTween} tween The tween to play.
   * @return {TimelineTween} This tween instance (for chaining calls).
   **/
  TimelineTween play(TimelineTween tween) {
    return call(tween.setPaused, [false]);
  }

  /**
   * Queues an action to to pause the specified tween.
   * @method pause
   * @param {TimelineTween} tween The tween to play. If null, it pauses this tween.
   * @return {TimelineTween} This tween instance (for chaining calls)
   **/
  TimelineTween pause(TimelineTween tween) {
    if (tween == null) return call(this.setPaused, [true]);
    return call(tween.setPaused, [true]);
  }

  /**
   * Advances the tween to a specified position.
   * @method setPosition
   * @param {Number} value The position to seek to in ticks.
   * @param {Number} actionsMode Optional parameter specifying how actions are handled (ie. call, set, play, pause):
   *      <code>TimelineTween.NONE</code> (0) - run no actions. <code>TimelineTween.LOOP</code> (1) - if new position is less than old, then run all actions
   *      between old and duration, then all actions between 0 and new. Defaults to <code>LOOP</code>. <code>TimelineTween.REVERSE</code> (2) - if new
   *      position is less than old, run all actions between them in reverse.
   * @return {Boolean} Returns true if the tween is complete (ie. the full tween has run & loop is false).
   **/
  bool setPosition(num value, [int actionsMode]) {
    if (value < 0) value = 0;
    if (actionsMode == null) actionsMode = 1;

    // normalize position:
    var t = value;
    var end = false;
    if (t >= duration) {
      if (loop) {
        t = t % duration;
      } else {
        t = duration;
        end = true;
      }
    }

    if (t == _prevPos) {
      return end;
    }

    var prevPos = _prevPos;
    position = _prevPos = t; // set this in advance in case an action modifies position.
    _prevPosition = value;

    // handle tweens:
    if (_target != null) {
      if (end) {
        // addresses problems with an ending zero length step.
        _updateTargetProps(null, 1);
      } else if (_steps.length > 0) {
        // find our new tween index:
        int i = 0;
        for (i = 0; i < _steps.length; i++) {
          if (_steps[i].t > t) break;
        }
        var step = _steps[i - 1];
        _stepPosition = t - step.t;
        _updateTargetProps(step, _stepPosition / step.d);
      }
    }

    // run actions:
    if (actionsMode != 0 && _actions.length > 0) {
      int actionPos = t.toInt();
      if (_prevActionPos != actionPos) {
        _prevActionPos = actionPos;
        _runActions(actionPos);
      }
    }

    if (end) {
      setPaused(true);
    }

    if (onChange != null) onChange(this);
    return end;
  }

  /**
   * Advances this tween by the specified amount of time in milliseconds (or ticks if <code>useTicks</code> is true).
   * This is normally called automatically by the TimelineTween engine (via <code>TimelineTween.tick</code>), but is exposed for advanced uses.
   * @method tick
   * @param {Number} delta The time to advance in milliseconds (or ticks if <code>useTicks</code> is true).
   **/
  void tick(num delta) {
    if (_paused) {
      return;
    }
    setPosition(_prevPosition + delta);
  }

  /**
   * Pauses or plays this tween.
   * @method setPaused
   * @param {Boolean} value Indicates whether the tween should be paused (true) or played (false).
   * @return {TimelineTween} This tween instance (for chaining calls)
   **/
  TimelineTween setPaused(bool value) {
    _paused = !!value;
    //TimelineTween._register(this, !value);
    return this;
  }

  /**
   * Returns a string representation of this object.
   * @method toString
   * @return {String} a string representation of the instance.
   **/
  String toString() {
    return "[TimelineTween]";
  }

  /**
   * @method _updateTargetProps
   * @param {Object} step
   * @param {Number} ratio
   * @protected
   **/
  void _updateTargetProps(TimelineStep step, num ratio) {
    var p0, p1, v, v0, v1, arr;
    num dv, dv0, dv1;
    if (step == null && ratio == 1) {
      p0 = p1 = _curQueueProps;
    } else {
      // apply ease to ratio.
      if (step.e != null) {
        ratio = step.e(ratio);
      }
      p0 = step.p0;
      p1 = step.p1;
    }

    for (var n in _initQueueProps.keys) {
      if ((v0 = p0[n]) == null) {
        p0[n] = v0 = _initQueueProps[n];
      }
      if ((v1 = p1[n]) == null) {
        p1[n] = v1 = v0;
      }

      if (v0 is num/*typeof number*/) {
        dv0 = v0.toDouble();
        dv1 = v1.toDouble();

        if (dv0 == dv1 || ratio == 0 || ratio == 1) {
          dv = ratio == 1 ? dv1 : dv0;
        } else {
          dv = dv0 + (dv1 - dv0) * ratio;
        }
      } else {
        // no interpolation for non-numeric
        v = ratio == 1 ? v1 : v0;
        dv = 0;
      }

      //_target[n] = v;
      //print("newValue $n = $v");
      if (_target is DisplayObject) {
        DisplayObject d = _target as DisplayObject;
        switch (n) {
          case "off":
            d.off = v as bool;
            break;
          case "x":
            d.x = dv;
            break;
          case "y":
            d.y = dv;
            break;
          case "rotation":
            d.rotation = dv;
            break;
          case "alpha":
            d.alpha = dv;
            break;
          case "scaleX":
            d.scaleX = dv;
            break;
          case "scaleY":
            d.scaleY = dv;
            break;
          case "skewX":
            d.skewX = dv;
            break;
          case "skewY":
            d.skewY = dv;
            break;
          case "regX":
            d.pivotX = dv;
            break;
          case "regY":
            d.pivotY = dv;
            break;
          case "startPosition":
            if (_target is MovieClip) (_target as MovieClip).startPosition = ratio == 1 ? v1 : v0;
            break;
          case "mode":
            if (_target is MovieClip) (_target as MovieClip).mode = v;
            break;
          case "loop":
            if (_target is MovieClip) (_target as MovieClip).loop = v as bool;
            break;
          case "graphics":
            if (_target is Shape) (_target as Shape).graphics = v as Graphics;
            break;
          case "textColor":
            if (_target is TextField) {
              var field = _target as TextField;
              if (v is String) field.textColor = int.parse(v.toString()); else if (v != null) field.textColor = dv.toInt();
            }
            break;
        }
      } else _target[n] = v;
    }
  }

  /**
   * @method _runActions
   * @param {Number} startPos
   * @param {Number} endPos
   * @param {Boolean} includeStart
   * @protected
   **/
  void _runActions(int curPos) {

    for (var i = 0; i < _actions.length; i++) {
      var action = _actions[i];
      if (action.t == curPos) {
        //if (action.p != null) Function.apply(action.f, action.p);
        action.f();
      }
    }
  }

  /**
   * @method _appendQueueProps
   * @param {Object} o
   * @protected
   **/
  Map<String, dynamic> _appendQueueProps(Map<String, dynamic> o) {
    var arr,
        oldValue = null,
        i,
        l,
        injectProps;
    for (var n in o.keys) {
      if (!_initQueueProps.containsKey(n)) {

        //oldValue = _target[n];
        if (_target is DisplayObject) {
          DisplayObject d = _target as DisplayObject;
          switch (n) {
            case "off":
              oldValue = d.off;
              break;
            case "x":
              oldValue = d.x;
              break;
            case "y":
              oldValue = d.y;
              break;
            case "rotation":
              oldValue = d.rotation;
              break;
            case "alpha":
              oldValue = d.alpha;
              break;
            case "scaleX":
              oldValue = d.scaleX;
              break;
            case "scaleY":
              oldValue = d.scaleY;
              break;
            case "skewX":
              oldValue = d.skewX;
              break;
            case "skewY":
              oldValue = d.skewY;
              break;
            case "regX":
              oldValue = d.pivotX;
              break;
            case "regY":
              oldValue = d.pivotY;
              break;
            case "startPosition":
              if (_target is MovieClip) oldValue = (_target as MovieClip).startPosition; else oldValue = null;
              break;
            case "mode":
              if (_target is MovieClip) oldValue = (_target as MovieClip).mode; else oldValue = null;
              break;
            case "loop":
              if (_target is MovieClip) oldValue = (_target as MovieClip).loop; else oldValue = null;
              break;
            case "graphics":
              if (target is Shape) oldValue = (target as Shape).graphics; else oldValue = null;
              break;
            case "textColor":
              if (target is TextField) oldValue = (target as TextField).textColor;
              break;
            default:
              print("TimelineTween._appendQueueProps: unknown property '$n'");
              continue;
          }
        } else {
          if (_target.containsKey(n)) oldValue = _target[n]; else oldValue = null;
        }

        _initQueueProps[n] = oldValue;
        ;
      } else if (_curQueueProps.containsKey(n)) {
        oldValue = _curQueueProps[n];
      }

      _curQueueProps[n] = o[n];
    }
    return _curQueueProps;
  }

  /**
   * @method _cloneProps
   * @param {Object} props
   * @protected
   **/
  Map<String, dynamic> _cloneProps(Map<String, dynamic> props) {
    var o = new Map<String, dynamic>();
    for (var n in props.keys) {
      o[n] = props[n];
    }
    return o;
  }

  /**
   * @method _addStep
   * @param {Object} o
   * @protected
   **/
  TimelineTween _addStep(TimelineStep o) {
    if (o.d > 0) {
      _steps.add(o);
      o.t = duration.toInt();
      duration += o.d;
    }
    return this;
  }

  /**
   * @method _addAction
   * @param {Object} o
   * @protected
   **/
  TimelineTween _addAction(TimelineAction o) {
    o.t = duration.toInt();
    _actions.add(o);
    return this;
  }

  /**
   * @method _set
   * @param {Object} props
   * @param {Object} o
   * @protected
   **/
  void _set(Map<String, dynamic> props, Map<String, dynamic> o) {
    for (var n in props.keys) {
      o[n] = props[n];
    }
  }
}
