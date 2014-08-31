part of stagexl.engine;

abstract class RenderLoopBase {

  num _renderTime = -1.0;
  int _requestId = null;

  //-------------------------------------------------------------------------------------------------

  void start() {
    _renderTime = -1.0;
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

    num renderTime = ensureNum(time) / 1000.0;

    if (_renderTime >= 0 && renderTime > _renderTime) {
      this.advanceTime(renderTime - _renderTime);
    }

    _renderTime = renderTime;
  }

}