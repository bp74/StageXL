part of '../display.dart';

class RenderLoop extends RenderLoopBase {
  final Juggler _juggler = Juggler();
  final List<Stage> _stages = <Stage>[];
  final EnterFrameEvent _enterFrameEvent = EnterFrameEvent(0);
  final ExitFrameEvent _exitFrameEvent = ExitFrameEvent();

  num _currentTime = 0.0;

  RenderLoop() {
    start();
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
