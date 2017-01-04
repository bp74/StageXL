part of stagexl.engine;

List _globalFrameListeners = new List();
num _globalFrameTime = double.MAX_FINITE;
int _globalFrameCallbackId = -1;

void _globalFrameRequest() {
  if (_globalFrameCallbackId == -1) {
    _globalFrameCallbackId = window.requestAnimationFrame((num frameTime) {
      var currentFrameTime = frameTime / 1000.0;
      var deltaTime = currentFrameTime - _globalFrameTime;
      _globalFrameTime = currentFrameTime;
      _globalFrameCallbackId = -1;
      _globalFrameRequest();

      for (var f in _globalFrameListeners.toList()) {
        f(deltaTime);
      }
    });
  }
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

abstract class RenderLoopBase {

  bool _running = false;

  void advanceTime(num deltaTime);

  void start() {
    _running = true;
    _globalFrameRequest();
    _globalFrameListeners.add(_onGlobalFrame);
  }

  void stop() {
    _running = false;
    _globalFrameListeners.remove(_onGlobalFrame);
  }

  void _onGlobalFrame(num deltaTime) {
    if (_running && deltaTime >= 0) {
      if (deltaTime is num) {
        this.advanceTime(deltaTime);
      }
    }
  }
}
