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

typedef void ChangeHandler(dynamic sender); // Tween or Timeline

class TimelineAction {
  int t;
  Function f;
  List<dynamic> p;

  TimelineAction(Function func, List<dynamic> params) {
    f = func;
    p = params;
  }
}

class TimelineStep {
  num d;
  int t;
  Map<String, dynamic> p0;
  Map<String, dynamic> p1;
  EaseFunction e;

  TimelineStep(num duration, Map<String, dynamic> start, EaseFunction ease, Map<String, dynamic> end) {
    d = duration;
    p0 = start;
    p1 = end;
    e = ease;
  }
}

class Timeline {
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
  Timeline(List<TimelineTween> tweens, Map<String, num> labels, Map<String, dynamic> props) {
    if (props != null) {
      loop = props.containsKey("loop") ? props["loop"] : false;
      ignoreGlobalPause = props.containsKey("ignoreGlobalPause") ? props["ignoreGlobalPause"] : false;
      onChange = props.containsKey("onChange") ? props["onChange"] : null;
    }
    if (tweens != null) {
      for (var i = 0; i < tweens.length; i++) addTween(tweens[i]);
    }
    setLabels(labels);
    if (props != null && props.containsKey("paused") && props["paused"] == true) {
      _paused = true;
    }
    //else { TimelineTween._register(this, true); }

    if (props != null && props.containsKey("position") && props["position"] != 0) {
      setPosition(props["position"], TimelineTween.NONE);
    }
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
    if (tween.duration > duration) {
      duration = tween.duration;
    }
    if (_prevPos >= 0) {
      tween.setPosition(_prevPos, TimelineTween.NONE);
    }
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
      if (tween.duration >= duration) {
        updateDuration();
      }
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
    if (value.isNaN || value < 0) {
      value = 0;
    }
    num t = loop ? value % duration : value;
    bool end = !loop && value >= duration;

    if (t == _prevPos) return end;
    _prevPosition = value;
    position = _prevPos = t; // in case an action changes the current frame.

    for (var i = 0; i < _tweens.length; i++) {
      _tweens[i].setPosition(t, actionsMode);
      if (t != _prevPos) return false; // an action changed this timeline's position.
    }
    if (end) {
      setPaused(true);
    }
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
    for (var i = 0; i < _tweens.length; i++) {
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
    setPosition(_prevPosition + delta);
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
      if (_labels.containsKey(positionOrLabel)) pos = _labels[positionOrLabel]; else print("Error: unkown label $positionOrLabel");
    } else pos = positionOrLabel.toDouble();
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

  /**
   * @method _goto
   * @protected
   **/
  void _goto(dynamic positionOrLabel) {
    var pos = resolve(positionOrLabel);
    if (pos != null) {
      setPosition(pos);
    }
  }

  void _advanceTime(num delta) {
    for (var i = 0; i < _tweens.length; i++) {
      var tween = _tweens[i];
      tween.tick(delta);
    }
  }
}
