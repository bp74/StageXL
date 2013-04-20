part of stagexl;

class RenderLoop {
  
  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime;
  Function _requestAnimationFrameCallback; // Cached closure to pass to requestAnimationFrame.

  _EventStreamIndex _enterFrameIndex;
  EnterFrameEvent _enterFrameEvent;

  RenderLoop() {
    
    _juggler = new Juggler();
    _stages = new List<Stage>();
    _renderTime = -1;

    _enterFrameIndex = _EventStreamIndex.enterFrame;
    _enterFrameEvent = new EnterFrameEvent(0);

    _requestAnimationFrameCallback = _onAnimationFrame;
    _requestAnimationFrame();
  }

  Juggler get juggler => _juggler;

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

  _requestAnimationFrame() {
    html.window.requestAnimationFrame(_requestAnimationFrameCallback); 
  }
  
  _onAnimationFrame(num currentTime) {
    
    _requestAnimationFrame();

    currentTime = currentTime.toDouble();
    
    if (_renderTime == -1) _renderTime = currentTime;
    if (_renderTime > currentTime) _renderTime = currentTime;

    num deltaTime = currentTime - _renderTime;
    num deltaTimeSec = deltaTime / 1000.0;
    num currentTimeSec = currentTime / 1000.0;
    
    if (deltaTime >= 1) {
      _renderTime = currentTime;
      _enterFrameEvent._passedTime = deltaTimeSec;
      _enterFrameIndex._dispatchEvent(_enterFrameEvent);
      _juggler.advanceTime(deltaTimeSec);

      for(int i = 0; i < _stages.length; i++) {
        var stage = _stages[i];
        stage.juggler.advanceTime(deltaTimeSec);
        stage.materialize(currentTimeSec, deltaTimeSec);
      }
    }
  }

  //-------------------------------------------------------------------------------------------------
  //-------------------------------------------------------------------------------------------------

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
  
}
