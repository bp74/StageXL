part of stagexl.display;

class RenderLoop extends RenderLoopBase {

  final Juggler _juggler = new Juggler();
  final List<Stage> _stages = new List<Stage>();
  final EnterFrameEvent _enterFrameEvent = new EnterFrameEvent(0);
  final ExitFrameEvent _exitFrameEvent = new ExitFrameEvent();
  final RenderEvent _renderEvent = new RenderEvent();

  bool _invalidate = false;
  num _currentTime = 0.0;

  RenderLoop() {
    this.start();
  }

  Juggler get juggler => _juggler;

  //-------------------------------------------------------------------------------------------------

  void invalidate() {
    _invalidate = true;
  }

  void addStage(Stage stage) {
    stage._renderLoop?.removeStage(stage);
    stage._renderLoop = this;
    _stages.add(stage);
  }

  void removeStage(Stage stage) {
    if (_stages.remove(stage)) {
      stage._renderLoop = null;
    }
  }

  //-------------------------------------------------------------------------------------------------

  @override
  void advanceTime(num deltaTime) {

    _currentTime += deltaTime;
    _enterFrameEvent.passedTime = deltaTime;
    _enterFrameEvent.dispatch();
    _juggler.advanceTime(deltaTime);

    for (int i = 0; i < _stages.length; i++) {
      _stages[i].juggler.advanceTime(deltaTime);
    }

    if (_invalidate) {
      _invalidate = false;
      _renderEvent.dispatch();
    }

    for (int i = 0; i < _stages.length; i++) {
      _stages[i].materialize(_currentTime, deltaTime);
    }

    _exitFrameEvent.dispatch();
  }
}
