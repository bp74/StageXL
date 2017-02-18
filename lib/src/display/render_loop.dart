part of stagexl.display;

class RenderLoop extends RenderLoopBase {

  final Juggler _juggler = new Juggler();
  final List<Stage> _stages = new List<Stage>();
  final EnterFrameEvent _enterFrameEvent = new EnterFrameEvent(0);
  final ExitFrameEvent _exitFrameEvent = new ExitFrameEvent();

  num _currentTime = 0.0;

  RenderLoop() {
    this.start();
  }

  Juggler get juggler => _juggler;

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

  @override
  void advanceTime(num deltaTime) {
    _currentTime += deltaTime;
    _enterFrameEvent.passedTime = deltaTime;
    _enterFrameEvent.dispatch();
    _juggler.advanceTime(deltaTime);
    _stages.forEach((s) => s.juggler.advanceTime(deltaTime));
    _stages.forEach((s) => s.materialize(_currentTime, deltaTime));
    _exitFrameEvent.dispatch();
  }
}
