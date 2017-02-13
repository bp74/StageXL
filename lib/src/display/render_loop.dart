part of stagexl.display;

class RenderLoop extends RenderLoopBase {

  final Juggler juggler = new Juggler();

  List<Stage> _stages = new List<Stage>();
  bool _invalidate = false;
  num _currentTime = 0.0;
  bool bMaterialized = false;

  EnterFrameEvent _enterFrameEvent = new EnterFrameEvent(0);
  ExitFrameEvent _exitFrameEvent = new ExitFrameEvent();
  RenderEvent _renderEvent = new RenderEvent();

  RenderLoop() {
    this.start();
  }

  //-------------------------------------------------------------------------------------------------

  void invalidate() {
    _invalidate = true;
  }

  void addStage(Stage stage) {

    if (stage.renderLoop != null) {
      stage.renderLoop.removeStage(stage);
    }

    if(stage.renderMode == StageRenderMode.AUTO_DIRTY){
      stage.onMouseMove.capture((e) => stage.dirty = true);
      stage.onTouchMove.capture((e) => stage.dirty = true);
      stage.onMouseWheel.capture((e) => stage.dirty = true);
    }

    _stages.add(stage);
    stage._renderLoop = this;
  }

  void removeStage(Stage stage) {
    if(stage.renderMode == StageRenderMode.AUTO_DIRTY) {
      stage.onMouseMove.cancelSubscriptions();
      stage.onTouchMove.cancelSubscriptions();
      stage.onMouseWheel.cancelSubscriptions();
    }

    if (stage.renderLoop == this) {
      _stages.remove(stage);
      stage._renderLoop = null;
    }
  }

  //-------------------------------------------------------------------------------------------------

  @override
  void advanceTime(num deltaTime) {

    _currentTime += deltaTime;

    _enterFrameEvent.passedTime = deltaTime;
    _enterFrameEvent.dispatch();

    juggler.advanceTime(deltaTime);

    for (int i = 0; i < _stages.length; i++) {
      _stages[i].juggler.advanceTime(deltaTime);
    }

    if (_invalidate) {
      _invalidate = false;
      _renderEvent.dispatch();
    }

    for (int i = 0; i < _stages.length; i++) {
      if(_stages[i].renderMode != StageRenderMode.AUTO_DIRTY || juggler.hasAnimatables || _stages[i].juggler.hasAnimatables || _stages[i].dirty){
        if(!bMaterialized){
          print("stage was dirty.");
          bMaterialized = true;
        }
        _stages[i].materialize(_currentTime, deltaTime);
        _stages[i].dirty = false;
      }
      else{
        if(bMaterialized){
          print("stage not dirty");
          bMaterialized = false;
        }
      }
    }

    _exitFrameEvent.dispatch();
  }
}
