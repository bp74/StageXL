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
  num _prevPos = -1; // ToDo: evaluate using a ._reset Boolean prop instead of -1.
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
    props = {
      "paused": true,
      "position": this.startPosition
    };
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
      _prevPosition = (_prevPos < 0) ? 0 : _prevPosition + df;
      timeline._advanceTime(df);
    }
    return true;
  }

  void _goto(positionOrLabel) {
    var pos = timeline.resolve(positionOrLabel);
    if (pos == null) return;
    // prevent _updateTimeline from overwriting the new position because of a reset:
    if (_prevPos == -1) {
      _prevPos = double.NAN;
    }
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
      // ToDo: this would be far more ideal if the _synchOffset was somehow provided by the parent, so that reparenting wouldn't cause problems and we can direct draw. Ditto for _off (though less important).
      tl.setPosition(startPosition + (mode == MovieClip.SINGLE_FRAME ? 0 : _synchOffset), TimelineTween.NONE);
    } else {
      tl.setPosition(_prevPos < 0 ? 0 : _prevPosition, actionsEnabled ? null : TimelineTween.NONE);
    }

    _prevPosition = tl._prevPosition;
    if (_prevPos == tl._prevPos) return;
    _prevPos = tl._prevPos;
    _currentFrame = _prevPos.toInt();

    for (var n in _managed.keys) {
      _managed[n] = 1;
    }

    for (var i = tweens.length - 1; i >= 0; i--) {
      TimelineTween tween = tweens[i];
      var target = tween._target;
      if (target == null || target == this) continue; // ToDo: this assumes this is the actions tween. Valid?
      int offset = tween._stepPosition.toInt();

      if (target is DisplayObject) {
        // motion tween.
        DisplayObject child = target as DisplayObject;
        _addManagedChild(child, offset);
      } else {
        // state tween.
        if (target.containsKey("state")) {
          List<dynamic> state = target["state"];
          _setState(state, offset);
        }
      }
    }

    for (var i = numChildren - 1; i >= 0; i--) {
      var id = getChildAt(i).displayObjectID;
      if (_managed[id] == 1) {
        removeChildAt(i);
        _managed.remove(id);
      }
    }
  }

  void _setState(List<dynamic> state, int offset) {
    if (state == null) return;
    for (var i = 0,
        l = state.length; i < l; i++) {
      var o = state[i];
      var target = o["t"];
      if (target is DisplayObject) {
        var d = target as DisplayObject;
        if (o.containsKey("p")) {
          var p = o["p"];
          for (var n in p.keys) {
            var v = p[n];
            num dv = v is num ? v.toDouble() : 0;
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
                if (target is MovieClip) (target as MovieClip).startPosition = dv.toInt();
                break;
              case "mode":
                if (target is MovieClip) (target as MovieClip).mode = v.toString();
                break;
              case "loop":
                if (target is MovieClip) (target as MovieClip).loop = v as bool;
                break;
              case "graphics":
                if (target is Shape) (target as Shape).graphics = v as Graphics;
                break;
              case "textColor":
                if (target is TextField) {
                  var field = target as TextField;
                  if (v is String) field.textColor = int.parse(v.toString()); else if (v != null) field.textColor = dv.toInt();
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
    if (child.off) {
      return;
    }
    addChild(child);

    if (child is MovieClip) {
      var mc = child;
      mc._synchOffset = offset;
      // ToDo: this does not precisely match Flash. Flash loses track of the clip if it is renamed or removed from the timeline, which causes it to reset.
      if (mc.mode == MovieClip.INDEPENDENT && mc.autoReset && !_managed.containsKey(child.displayObjectID)) {
        mc._reset();
      }
    }
    _managed[child.displayObjectID] = 2;
  }

}



