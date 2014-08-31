part of stagexl.engine;

abstract class RenderLoopBase {

  num _renderTime = double.MAX_FINITE;
  int _requestId = null;

  //-------------------------------------------------------------------------------------------------

  void start() {
    _renderTime = double.MAX_FINITE;
    _requestAnimationFrame();
  }

  void stop() {
    _cancelAnimationFrame();
  }

  void advanceTime(num deltaTime);

  //-------------------------------------------------------------------------------------------------

  _requestAnimationFrame() {
    if (_requestId == null) {
      _requestId = window.requestAnimationFrame(_onAnimationFrame);
    }
  }

  _cancelAnimationFrame() {
    if (_requestId != null) {
      window.cancelAnimationFrame(_requestId);
      _requestId = null;
    }
  }

  _onAnimationFrame(num time) {

    _requestId = null;
    _requestAnimationFrame();

    num oldRenderTime = _renderTime;
    num newRenderTime = _renderTime = ensureNum(time) / 1000.0;

    if (newRenderTime > oldRenderTime) {
      this.advanceTime(newRenderTime - oldRenderTime);
    }
  }

}
