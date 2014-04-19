part of stagexl;

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

class MovieClip extends Sprite {
  /**
   * Read-only. The MovieClip will advance independently of its parent, even if its parent is paused.
   * This is the default mode.
   **/
  static const String INDEPENDENT = "independent";

  /**
   * Read-only. The MovieClip will only display a single frame (as determined by the startPosition property).
   **/
  static const String SINGLE_FRAME = "single";

  /**
   * Read-only. The MovieClip will be advanced only when it's parent advances and will be synched to the position of
   * the parent MovieClip.
   **/
  static const String SYNCHED = "synched";

  /**
   * Controls how this MovieClip advances its time. Must be one of 0 (INDEPENDENT), 1 (SINGLE_FRAME), or 2 (SYNCHED).
   * See each constant for a description of the behaviour.
   **/
  String mode;

  /**
   * Specifies what the first frame to play in this movieclip, or the only frame to display if mode is SINGLE_FRAME.
   */
  int startPosition = 0;

  /**
   * Specifies the timeline progression speed.
   * If =0, uses the stage's frameRate
   */
  int frameRate = 0;

  /**
   * Indicates whether this MovieClip should loop when it reaches the end of its timeline.
   */
  bool loop = true;

  /**
   * Read-Only. The current frame of the movieclip.
   */
  int get currentFrame {
    return _currentFrame;
  }

  /**
   * Read-Only. The number of frames of the movieclip.
   */
  int get totalFrames {
    return timeline.duration.toInt();
  }

  /**
   * The Timeline that is associated with this MovieClip. This is created automatically when the MovieClip
   * instance is initialized.
   */
  Timeline timeline;

  /**
   * If true, the MovieClip's position will not advance when ticked.
   */
  bool paused = false;
  
  /**
   * If true, actions in this MovieClip's tweens will be run when the playhead advances.
   */
  bool actionsEnabled = true;
  
  /**
   * If true, the MovieClip will automatically be reset to its first frame whenever the timeline adds
   * it back onto the display list. This only applies to MovieClip instances with mode=INDEPENDENT.
   * <br><br>
   * For example, if you had a character animation with a "body" child MovieClip instance
   * with different costumes on each frame, you could set body.autoReset = false, so that
   * you can manually change the frame it is on, without worrying that it will be reset
   * automatically.
   */
  bool autoReset = true;

// properties:

  int _currentFrame = 0;
  int _synchOffset = 0;  
  num _prevPos = -1; // TODO: evaluate using a ._reset Boolean prop instead of -1.
  num _prevPosition = 0;
  final Map<int, int> _managed = new Map<int, int>();
  Map<String, dynamic> props;
  
  /**
   * The MovieClip class associates a TimelineTween Timeline with a {{#crossLink "Sprite"}}{{/crossLink}}. It allows
   * you to create objects which encapsulate timeline animations, state changes, and synched actions. Due to the
   * complexities inherent in correctly setting up a MovieClip, it is largely intended for tool output.
   *
   * Currently MovieClip only works properly if it is tick based (as opposed to time based) though some concessions have
   * been made to support time-based timelines in the future.
   * 
   * @param mode Initial value for the mode property. One of MovieClip.INDEPENDENT, MovieClip.SINGLE_FRAME, or MovieClip.SYNCHED.
   * @param startPosition Initial value for the startPosition property.
   * @param loop Initial value for the loop property.
   * @param labels A hash of labels to pass to the timeline instance associated with this MovieClip.
   **/
  MovieClip([String mode, int startPosition, bool loop, Map<String, num> labels])
    : super() {
    
    this.mode = mode != null ? mode : MovieClip.INDEPENDENT;
    this.startPosition = startPosition != null ? startPosition : 0;
    this.loop = loop != null ? loop : true;
    props = {"paused":true, "position":this.startPosition};
    timeline = new Timeline(null, labels, props);
  }
  
// public methods:
  /**
   * Returns true or false indicating whether the display object would be visible if drawn to a canvas.
   * This does not account for whether it would be visible within the boundaries of the stage.
   * NOTE: This method is mainly for internal use, though it may be useful for advanced uses.
   * @method isVisible
   * @return {Boolean} Boolean indicating whether the display object would be visible if drawn to a canvas
   **/
  bool isVisible() {
    // children are placed in draw, so we can't determine if we have content.
    return !!(this.visible && this.alpha > 0 && this.scaleX != 0 && this.scaleY != 0);
  }

  /**
   * Advances timelines and places children depending on the currentframe
   * NOTE: automatically called by .render()
   */
  void advance(num deltaTime) {
    _advanceTime(deltaTime);
    _updateTimeline();
  }
  
  /**
   * Draws the display object into the specified context ignoring it's visible, alpha, shadow, and transform.
   * Returns true if the draw was handled (useful for overriding functionality).
   * NOTE: This method is mainly for internal use, though it may be useful for advanced uses.
   * @param {CanvasRenderingContext2D} ctx The canvas 2D context object to draw into.
   * @param {Boolean} ignoreCache Indicates whether the draw operation should ignore any current cache.
   * For example, used for drawing the cache (to prevent it from simply drawing an existing cache back
   * into itself).
   **/
  void render(RenderState renderState) {
    advance(renderState.deltaTime);
    super.render(renderState);
  }
  
  /**
   * Sets paused to false.
   **/
  void play() {
    paused = false;
  }
  
  /**
   * Sets paused to true.
   **/
  void stop() {
    paused = true;
  }
  
  /**
   * Advances this movie clip to the specified position or label and sets paused to false.
   **/
  void gotoAndPlay(dynamic positionOrLabel) {
    paused = false;
    _goto(positionOrLabel);
  }
  
  /**
   * Advances this movie clip to the specified position or label and sets paused to true.
   **/
  void gotoAndStop(dynamic positionOrLabel) {
    paused = true;
    _goto(positionOrLabel);
  }
  
  /**
   * Returns a string representation of this object.
   * @return {String} a string representation of the instance.
   **/
  String toString() {
    return "[MovieClip (name=$name)]";
  }
  
// private methods

  bool _advanceTime(num time) {
    if (!paused && mode == MovieClip.INDEPENDENT && stage != null) {
      var f = frameRate > 0 ? frameRate : stage.frameRate;
      num sPerFrame = 1 / f;
      num df = min(1, time / sPerFrame);
      _prevPosition = (_prevPos < 0) ? 0 : _prevPosition+df;
      timeline._advanceTime(df);
    }
    return true;
  }
  
  void _goto(positionOrLabel) {
    var pos = timeline.resolve(positionOrLabel);
    if (pos == null) return;
    // prevent _updateTimeline from overwriting the new position because of a reset:
    if (_prevPos == -1) { _prevPos = double.NAN; }
    _prevPosition = pos;
    _updateTimeline();
  }
  
  void _reset() {
    _prevPos = -1;
    _currentFrame = 0;
  }
  
  void _updateTimeline() {
    var tl = timeline;
    var tweens = tl._tweens;
    var synched = mode != MovieClip.INDEPENDENT;
    tl.loop = loop;
    
    // update timeline position, ignoring actions if this is a graphic.
    if (synched) {
      // TODO: this would be far more ideal if the _synchOffset was somehow provided by the parent, so that reparenting wouldn't cause problems and we can direct draw. Ditto for _off (though less important).
      tl.setPosition(startPosition + (mode==MovieClip.SINGLE_FRAME?0:_synchOffset), TimelineTween.NONE);
    } else {
      tl.setPosition(_prevPos < 0 ? 0 : _prevPosition, actionsEnabled ? null : TimelineTween.NONE);
    }
    
    _prevPosition = tl._prevPosition;
    if (_prevPos == tl._prevPos) 
      return;
    _prevPos = tl._prevPos;
    _currentFrame = _prevPos.toInt();
    
    for (var n in _managed.keys) { _managed[n] = 1; }
    
    for (var i=tweens.length-1; i>=0; i--) {
      TimelineTween tween = tweens[i];
      var target = tween._target;
      if (target == null || target == this) continue; // TODO: this assumes this is the actions tween. Valid?
      int offset = tween._stepPosition.toInt();
      
      if (target is DisplayObject) {
        // motion tween.
        DisplayObject child = target as DisplayObject; 
        _addManagedChild(child, offset);
      } 
      else {
        // state tween.
        if (target.containsKey("state")) {
          List<dynamic> state = target["state"];
          _setState(state, offset);
        }
      }
    }
    
    for (var i=_children.length-1; i>=0; i--) {
      var id = _children[i]._id;
      if (_managed[id] == 1) {
        removeChildAt(i);
        _managed.remove(id);
      }
    }
  }
  
  void _setState(List<dynamic> state, int offset) {
    if (state == null) return;
    for (var i=0,l=state.length;i<l;i++) {
      var o = state[i];
      var target = o["t"];
      if (target is DisplayObject)
      {
        var d = target as DisplayObject;
        if (o.containsKey("p"))
        {
          var p = o["p"];
          for(var n in p.keys)
          {
            var v = p[n];
            num dv = v is num ? v.toDouble() : 0;  
            switch(n)
            {
              case "off": d.off = v as bool; break;
              case "x": d.x = dv; break;
              case "y": d.y = dv; break;
              case "rotation": d.rotation = dv; break;
              case "alpha": d.alpha = dv; break;
              case "scaleX": d.scaleX = dv; break;
              case "scaleY": d.scaleY = dv; break;
              case "skewX": d.skewX = dv; break;
              case "skewY": d.skewY = dv; break;
              case "regX": d.pivotX = dv; break;
              case "regY": d.pivotY = dv; break;
              case "startPosition":
                if (target is MovieClip)
                  (target as MovieClip).startPosition = dv.toInt();
                break;
              case "mode":
                if (target is MovieClip)
                  (target as MovieClip).mode = v.toString();
                break;
              case "loop":
                if (target is MovieClip)
                  (target as MovieClip).loop = v as bool;
                break;
              case "graphics":
                if (target is Shape)
                  (target as Shape).graphics = v as Graphics;
                break;
              case "textColor":
                if (target is TextField) {
                  var field = target as TextField;
                  if (v is String) field.textColor = int.parse(v.toString());
                  else if (v != null) field.textColor = dv.toInt();
                }
                break;
            }
          }
        }
        _addManagedChild(d, offset);
      }
    }
  }
  
  /**
   * Adds a child to the timeline, and sets it up as a managed child.
   **/
  void _addManagedChild(DisplayObject child, int offset) {
    if (child._off) { return; }
    addChild(child);
    
    if (child is MovieClip) {
      var mc = child;
      mc._synchOffset = offset;
      // TODO: this does not precisely match Flash. Flash loses track of the clip if it is renamed or removed from the timeline, which causes it to reset.
      if (mc.mode == MovieClip.INDEPENDENT && mc.autoReset && !_managed.containsKey(child._id)) { mc._reset(); }
    }
    _managed[child._id] = 2;
  }
  
}


typedef void ChangeHandler(dynamic sender); // Tween or Timeline


class Timeline
{
  /**
  * Causes this timeline to continue playing when a global pause is active.
  **/
  bool ignoreGlobalPause = false;
  
  /**
   * Read-only property specifying the total duration of this timeline in ticks.
   * This value is usually automatically updated as you modify the timeline. See updateDuration for more information.
   **/
  num duration = 1;
  
  /**
   * If true, the timeline will loop when it reaches the end. Can be set via the props param.

   **/
  bool loop = false;
  
  /**
   * Called, with a single parameter referencing this timeline instance, whenever the timeline's position changes.
   **/
  ChangeHandler onChange = null;
  
  /**
   * Read-only. The current normalized position of the timeline. This will always be a value between 0 and duration.
   * Changing this property directly will have no effect.
   **/
  num position = null;

// private properties:
  
  bool _paused = false;
  final List<TimelineTween> _tweens = new List<TimelineTween>();
  Map<String, num> _labels;
  num _prevPosition = 0;
  num _prevPos = -1;
  
  /**
   * The Timeline class synchronizes multiple tweens and allows them to be controlled as a group. Please note that if a
   * timeline is looping, the tweens on it may appear to loop even if the "loop" property of the tween is false.
   * @class Timeline
   * @param tweens An array of Tweens to add to this timeline. See addTween for more info.
   * @param labels An object defining labels for using gotoAndPlay/Stop. See {{#crossLink "Timeline/setLabels"}}{{/crossLink}}
   * for details.
   * @param props The configuration properties to apply to this tween instance (ex. {loop:true}). All properties default to
   * false. Supported props are:<UL>
   *    <LI> loop: sets the loop property on this tween.</LI>
   *    <LI> ignoreGlobalPause: sets the ignoreGlobalPause property on this tween.</LI>
   *    <LI> paused: indicates whether to start the tween paused.</LI>
   *    <LI> position: indicates the initial position for this timeline.</LI>
   *    <LI> onChanged: specifies an onChange handler for this timeline.</LI>
   * </UL>
   * @constructor
   **/
  Timeline(List<TimelineTween> tweens, Map<String, num> labels, Map<String, dynamic> props)
  {
    if (props != null) {
      loop = props.containsKey("loop") ? props["loop"] : false;
      ignoreGlobalPause = props.containsKey("ignoreGlobalPause") ? props["ignoreGlobalPause"] : false;
      onChange = props.containsKey("onChange") ? props["onChange"] : null;
    }
    if (tweens != null) {
      for(var i=0; i<tweens.length; i++)
        addTween(tweens[i]);
    }
    setLabels(labels);
    if (props != null && props.containsKey("paused") && props["paused"] == true) { _paused = true; }
    //else { TimelineTween._register(this, true); }
    
    if (props != null && props.containsKey("position") && props["position"] != 0) { 
      setPosition(props["position"], TimelineTween.NONE); }
  }
  
  /** 
   * Adds one or more tweens (or timelines) to this timeline. The tweens will be paused (to remove them from the normal ticking system)
   * and managed by this timeline. Adding a tween to multiple timelines will result in unexpected behaviour.
   * @param tween The tween(s) to add. Accepts multiple arguments.
   * @return TimelineTween The first tween that was passed in.
   **/
  TimelineTween addTween(TimelineTween tween) {
    if (tween == null) return null;
    removeTween(tween);
    _tweens.add(tween);
    tween.setPaused(true);
    tween._paused = false;
    if (tween.duration > duration) { duration = tween.duration; }
    if (_prevPos >= 0) { tween.setPosition(_prevPos, TimelineTween.NONE); }
    return tween;
  }

  /** 
   * Removes one or more tweens from this timeline.
   * @param tween The tween(s) to remove. Accepts multiple arguments.
   * @return Boolean Returns true if all of the tweens were successfully removed.
   **/
  bool removeTween(TimelineTween tween) {
    if (tween == null) return false;
    assert(tween is TimelineTween);
    var index = _tweens.indexOf(tween);
    if (index != -1) {
      _tweens.removeAt(index);
      if (tween.duration >= duration) { updateDuration(); }
      return true;
    } 
    return false;
  }
  
  /** 
   * Adds a label that can be used with gotoAndPlay/Stop.
   * @param label The label name.
   * @param position The position this label represents.
   **/
  void addLabel(String label, num position) {
    _labels[label] = position;
  }

  /** 
   * Defines labels for use with gotoAndPlay/Stop. Overwrites any previously set labels.
   * @param o An object defining labels for using gotoAndPlay/Stop in the form {labelName:time} where time is in ticks.
   **/
  void setLabels(Map<String, int> o) {
    _labels = o != null ? o : new Map<String, int>();
  }
  
  /** 
   * Unpauses this timeline and jumps to the specified position or label.
   * @method gotoAndPlay
   * @param positionOrLabel The position in ticks or label to jump to.
   **/
  void gotoAndPlay(dynamic positionOrLabel) {
    setPaused(false);
    _goto(positionOrLabel);
  }
  
  /** 
   * Pauses this timeline and jumps to the specified position or label.
   * @method gotoAndStop
   * @param positionOrLabel The position in ticks or label to jump to.
   **/
  void gotoAndStop(dynamic positionOrLabel) {
    setPaused(true);
    _goto(positionOrLabel);
  }
  
  /** 
   * Advances the timeline to the specified position.
   * @param value The position to seek to in ticks.
   * @param actionsMode Optional parameter specifying how actions are handled. See TimelineTween.setPosition for more details.
   * @return Boolean Returns true if the timeline is complete (ie. the full timeline has run & loop is false).
   **/
  bool setPosition(num value, [int actionsMode]) {
    if (value.isNaN || value < 0) { value = 0; }
    num t = loop ? value%duration : value;
    bool end = !loop && value >= duration;
    
    if (t == _prevPos) return end;
    _prevPosition = value;
    position = _prevPos = t; // in case an action changes the current frame.
    
    for(var i=0; i<_tweens.length; i++) {
      _tweens[i].setPosition(t, actionsMode);
      if (t != _prevPos) return false; // an action changed this timeline's position.
    }
    if (end) { setPaused(true); }
    if (onChange != null) onChange(this);
    return end;
  }
  
  /** 
   * Pauses or plays this timeline.
   * @param value Indicates whether the tween should be paused (true) or played (false).
   **/
  void setPaused(bool value) {
    _paused = !!value;
    //TimelineTween._register(this, !value); 
  }
  
  /** 
   * Recalculates the duration of the timeline.
   * The duration is automatically updated when tweens are added or removed, but this method is useful 
   * if you modify a tween after it was added to the timeline.
   * @method updateDuration
   **/
  void updateDuration() {
    duration = 0;
    for(var i=0; i<_tweens.length; i++) {
      var tween = _tweens[i];
      if (tween.duration > duration) duration = tween.duration;
    }
  }
  
  /** 
   * Advances this timeline by the specified amount of time in ticks.
   * This is normally called automatically by the TimelineTween engine (via TimelineTween.tick), but is exposed for advanced uses.
   * @param delta The time to advance in ticks.
   **/
  void tick(num delta) {
    setPosition(_prevPosition+delta);
  }
   
  /** 
   * If a numeric position is passed, it is returned unchanged. If a string is passed, the position of the
   * corresponding frame label will be returned, or null if a matching label is not defined.
   * @param positionOrLabel A numeric position value or label string.
   **/
  num resolve(dynamic positionOrLabel) {
    num pos = _prevPosition;
    if (positionOrLabel == null) return null;
    if (positionOrLabel is String) {
      if (_labels.containsKey(positionOrLabel))
        pos = _labels[positionOrLabel];
      else
        print("Error: unkown label $positionOrLabel");
    }
    else pos = positionOrLabel.toDouble();
    if (pos.isNaN) pos = _prevPosition;
    return pos;
  }

  /**
  * Returns a string representation of this object.
  * @method toString
  * @return {String} a string representation of the instance.
  **/
  String toString() {
    return "[Timeline]";
  }
  
// private methods:
  /**
   * @method _goto
   * @protected
   **/
  void _goto(dynamic positionOrLabel) {
    var pos = resolve(positionOrLabel);
    if (pos != null) { setPosition(pos); }
  }
  
  void _advanceTime(num delta) {
    for(var i=0; i<_tweens.length; i++) {
      var tween = _tweens[i];
      tween.tick(delta);
    }
  }
}

class TimelineStep 
{
  num d;
  int t;
  Map<String, dynamic> p0;
  Map<String, dynamic> p1;
  EaseFunction e;
  
  TimelineStep (num duration, Map<String, dynamic> start, EaseFunction ease, Map<String, dynamic> end)
  {
    d = duration;
    p0 = start;
    p1 = end;
    e = ease;
  }
}

class TimelineAction
{
  int t;
  Function f;
  List<dynamic> p;
  
  TimelineAction (Function func, List<dynamic> params)
  {
    f = func;
    p = params;
  }
}


// TODO: possibly add a END actionsMode (only runs actions that == position)?
// TODO: evaluate a way to decouple paused from tick registration.

/**
 * A TimelineTween instance tweens properties for a single target. Instance methods can be chained for easy construction and sequencing:
 *
 * <h4>Example</h4>
 *
 *      target.alpha = 1;
 *      TimelineTween.get(target)
 *           .wait(500)
 *           .to({alpha:0, visible:false}, 1000)
 *           .call(onComplete);
 *      function onComplete() {
 *        //TimelineTween complete
 *      }
 *
 * Multiple tweens can point to the same instance, however if they affect the same properties there could be unexpected
 * behaviour. To stop all tweens on an object, use {{#crossLink "TimelineTween/removeTweens"}}{{/crossLink}} or pass <code>override:true</code>
 * in the props argument.
 *
 *      TimelineTween.get(target, {override:true}).to({x:100});
 *
 * Subscribe to the "change" event to get notified when a property of the target is changed.
 *
 *      TimelineTween.get(target, {override:true}).to({x:100}).addEventListener("change", handleChange);
 *      function handleChange(event) {
 *          // The tween changed.
 *      }
 *
 * See the TimelineTween {{#crossLink "TimelineTween/get"}}{{/crossLink}} method for additional param documentation.
 */
class TimelineTween
{
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
      assert(target == null); // TODO
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
      // TODO: this approach might fail if a dev is using sealed objects in ES5
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
    
// public properties:
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
  
// constructor:
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
    
    if (props != null && props.containsKey("paused") && props["paused"] == true) { _paused = true; }
    //else { TimelineTween._register(this,true); }
    if (props != null && props.containsKey("position")) { 
      setPosition(props["position"], TimelineTween.NONE); }
  }
  
// public methods:
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
    if (duration.isNaN || duration <= 0) { return this; }
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
  
  // TODO: add clarification between this and a 0 duration .to:
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
    return _addAction(new TimelineAction(_set, [props, target != null ? target :
        _target]));
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
      if (loop) { t = t%duration; }
      else {
        t = duration;
        end = true;
      }
    }
    
    if (t == _prevPos) { return end; }
    
    var prevPos = _prevPos;
    position = _prevPos = t; // set this in advance in case an action modifies position.
    _prevPosition = value;
    
    // handle tweens:
    if (_target != null) {
      if (end) {
        // addresses problems with an ending zero length step.
        _updateTargetProps(null,1);
      } 
      else if (_steps.length > 0) {
        // find our new tween index:
        int i=0;
        for(i=0; i<_steps.length; i++) {
          if (_steps[i].t > t) break;
        }
        var step = _steps[i-1];
        _stepPosition = t-step.t;
        _updateTargetProps(step,_stepPosition/step.d);
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

    if (end) { setPaused(true); }
    
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
    if (_paused) { return; }
    setPosition(_prevPosition+delta);
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
  
// private methods:
  /**
   * @method _updateTargetProps
   * @param {Object} step
   * @param {Number} ratio
   * @protected
   **/
  void _updateTargetProps(TimelineStep step, num ratio) {
    var p0,p1,v,v0,v1,arr;
    num dv, dv0, dv1;
    if (step == null && ratio == 1) {
      p0 = p1 = _curQueueProps;
    } else {
      // apply ease to ratio.
      if (step.e != null) { ratio = step.e(ratio); }
      p0 = step.p0;
      p1 = step.p1;
    }

    for (var n in _initQueueProps.keys) {
      if ((v0 = p0[n]) == null) { p0[n] = v0 = _initQueueProps[n]; }
      if ((v1 = p1[n]) == null) { p1[n] = v1 = v0; }
      
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
        switch(n)
        {
          case "off": d.off = v as bool; break;
          case "x": d.x = dv; break;
          case "y": d.y = dv; break;
          case "rotation": d.rotation = dv; break;
          case "alpha": d.alpha = dv; break;
          case "scaleX": d.scaleX = dv; break;
          case "scaleY": d.scaleY = dv; break;
          case "skewX": d.skewX = dv; break;
          case "skewY": d.skewY = dv; break;
          case "regX": d.pivotX = dv; break;
          case "regY": d.pivotY = dv; break;
          case "startPosition":
            if (_target is MovieClip)
              (_target as MovieClip).startPosition = ratio == 1 ? v1 : v0;
            break;
          case "mode":
            if (_target is MovieClip)
              (_target as MovieClip).mode = v;
            break;
          case "loop":
            if (_target is MovieClip)
              (_target as MovieClip).loop = v as bool;
            break;
          case "graphics":
            if (_target is Shape)
              (_target as Shape).graphics = v as Graphics;
            break;
          case "textColor":
            if (_target is TextField) {
              var field = _target as TextField;
              if (v is String) field.textColor = int.parse(v.toString());
              else if (v != null) field.textColor = dv.toInt();
            }
            break;
        }
      }
      else _target[n] = v;
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
    var arr,oldValue = null,i, l, injectProps;
    for (var n in o.keys) {
      if (!_initQueueProps.containsKey(n)) {
        
        //oldValue = _target[n];
        if (_target is DisplayObject)
        {
          DisplayObject d = _target as DisplayObject;
          switch(n)
          {
            case "off": oldValue = d.off; break;
            case "x": oldValue = d.x; break;
            case "y": oldValue = d.y; break;
            case "rotation": oldValue = d.rotation; break;
            case "alpha": oldValue = d.alpha; break;
            case "scaleX": oldValue = d.scaleX; break;
            case "scaleY": oldValue = d.scaleY; break;
            case "skewX": oldValue = d.skewX; break;
            case "skewY": oldValue = d.skewY; break;
            case "regX": oldValue = d.pivotX; break;
            case "regY": oldValue = d.pivotY; break;
            case "startPosition": 
              if (_target is MovieClip)
                oldValue = (_target as MovieClip).startPosition;
              else oldValue = null;
              break;
            case "mode": 
              if (_target is MovieClip)
                oldValue = (_target as MovieClip).mode;
              else oldValue = null;
              break;
            case "loop": 
              if (_target is MovieClip)
                oldValue = (_target as MovieClip).loop;
              else oldValue = null;
              break;
            case "graphics":
              if (target is Shape)
                oldValue = (target as Shape).graphics;
              else oldValue = null;
              break;
            case "textColor":
              if (target is TextField)
                oldValue = (target as TextField).textColor;
              break;
            default:
              print("TimelineTween._appendQueueProps: unknown property '$n'");
              continue;
          }
        }
        else {
          if (_target.containsKey(n)) oldValue = _target[n];
          else oldValue = null;
        }
        
        _initQueueProps[n] = oldValue;;
      } 
      else if (_curQueueProps.containsKey(n)) {
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
