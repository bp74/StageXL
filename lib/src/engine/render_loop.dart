part of stagexl;

class RenderLoop {

  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime;
  Function _requestAnimationFrameCallback; // Cached closure to pass to requestAnimationFrame.
  bool _invalidate;
  int _requestId;

  EnterFrameEvent _enterFrameEvent;
  ExitFrameEvent _exitFrameEvent;
  RenderEvent _renderEvent;

  RenderLoop() {

    _juggler = new Juggler();
    _stages = new List<Stage>();
    _renderTime = -1;
    _invalidate = false;

    _enterFrameEvent = new EnterFrameEvent(0);
    _exitFrameEvent = new ExitFrameEvent();
    _renderEvent = new RenderEvent();

    _requestId = null;
    _requestAnimationFrameCallback = _onAnimationFrame;
    _requestAnimationFrame();
  }

  Juggler get juggler => _juggler;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  void start() {
    _renderTime = -1;
    _requestAnimationFrame();
  }

  void stop() {
    _cancelAnimationFrame();
  }

  void invalidate() {
    _invalidate = true;
  }

  void addStage(Stage stage) {

    if (stage.renderLoop != null) {
      stage.renderLoop.removeStage(stage);
    }

    _stages.add(stage);
    stage._renderLoop = this;
  }

  void removeStage(Stage stage) {

    if (stage.renderLoop == this) {
      _stages.remove(stage);
      stage._renderLoop = null;
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _requestAnimationFrame() {
    if (_requestId == null) {
      _requestId = html.window.requestAnimationFrame(_requestAnimationFrameCallback);
    }
  }

  _cancelAnimationFrame() {
    if (_requestId != null) {
      html.window.cancelAnimationFrame(_requestId);
      _requestId = null;
    }
  }

  _onAnimationFrame(num currentTime) {

    _requestId = null;
    _requestAnimationFrame();

    currentTime = currentTime.toDouble();

    if (_renderTime == -1) _renderTime = currentTime;
    if (_renderTime > currentTime) _renderTime = currentTime;

    var deltaTime = currentTime - _renderTime;
    var deltaTimeSec = deltaTime / 1000.0;
    var currentTimeSec = currentTime / 1000.0;
    var invalidate = false;

    if (deltaTime >= 1) {
      _renderTime = currentTime;
      _enterFrameEvent._passedTime = deltaTimeSec;
      _dispatchBroadcastEvent(_enterFrameEvent, _enterFrameSubscriptions);

      _juggler.advanceTime(deltaTimeSec);

      for(int i = 0; i < _stages.length; i++) {
        _stages[i].juggler.advanceTime(deltaTimeSec);
      }

      if (_invalidate) {
        _invalidate = false;
        _dispatchBroadcastEvent(_renderEvent, _renderSubscriptions);
      }

      for(int i = 0; i < _stages.length; i++) {
        _stages[i].materialize(currentTimeSec, deltaTimeSec);
      }

      _dispatchBroadcastEvent(_exitFrameEvent, _exitFrameSubscriptions);
    }
  }
}
