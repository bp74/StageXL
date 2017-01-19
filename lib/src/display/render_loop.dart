part of stagexl.display;

class RenderLoop extends RenderLoopBase {

  final Juggler juggler = new Juggler();

  List<Stage> stages = new List<Stage>();
  bool bInvalidate = false;
  num currentTime = 0.0;

  EnterFrameEvent enterFrameEvent = new EnterFrameEvent(0);
  ExitFrameEvent exitFrameEvent = new ExitFrameEvent();
  RenderEvent renderEvent = new RenderEvent();

  RenderLoop() {
    this.start();
  }

  //-------------------------------------------------------------------------------------------------

  void invalidate() {
    bInvalidate = true;
  }

  void addStage(Stage stage) {

    if (stage.renderLoop != null) {
      stage.renderLoop.removeStage(stage);
    }

    stages.add(stage);
    stage._renderLoop = this;
  }

  void removeStage(Stage stage) {

    if (stage.renderLoop == this) {
      stages.remove(stage);
      stage._renderLoop = null;
    }
  }

  //-------------------------------------------------------------------------------------------------

  @override
  void advanceTime(num deltaTime) {

    currentTime += deltaTime;

    enterFrameEvent.passedTime = deltaTime;
    enterFrameEvent.dispatch();

    juggler.advanceTime(deltaTime);

    for (int i = 0; i < stages.length; i++) {
      stages[i].juggler.advanceTime(deltaTime);
    }

    if (bInvalidate) {
      bInvalidate = false;
      renderEvent.dispatch();
    }

    for (int i = 0; i < stages.length; i++) {
      stages[i].materialize(currentTime, deltaTime);
    }

    exitFrameEvent.dispatch();
  }
}
