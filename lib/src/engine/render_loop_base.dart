part of stagexl.engine;

List _globalFrameListeners = new List();
bool _globalFrameLoop = _frameLoopInitializer();
num _globalFrameTime = double.MAX_FINITE;

bool _frameLoopInitializer() {
  window.requestAnimationFrame(_animationFrame);
  return true;
}

void _animationFrame(num frameTime) {
  var frameListeners = _globalFrameListeners.toList(growable: false);
  var currentFrameTime = ensureNum(frameTime) / 1000.0;
  var deltaTime = currentFrameTime - _globalFrameTime;

  for (int i = 0; i < frameListeners.length; i++) {
    frameListeners[i](deltaTime);
  }

  _globalFrameTime = currentFrameTime;
  window.requestAnimationFrame(_animationFrame);
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

abstract class RenderLoopBase {
  bool _running = false;

  RenderLoopBase() {
    var initialize = _globalFrameLoop;
  }

  void advanceTime(num deltaTime);

  void start() {
    _running = true;
    _globalFrameListeners.add(_onGlobalFrame);
  }

  void stop() {
    _running = false;
    _globalFrameListeners.remove(_onGlobalFrame);
  }

  void _onGlobalFrame(num deltaTime) {
    if (_running && deltaTime >= 0) {
      if (deltaTime is num) this.advanceTime(deltaTime);
    }
  }
}
