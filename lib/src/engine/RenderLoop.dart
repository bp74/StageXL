part of stagexl;

class RenderLoop {
  
  Juggler _juggler;
  List<Stage> _stages;
  num _renderTime;
  Function _requestAnimationFrameCallback; // Cached closure to pass to requestAnimationFrame.

  EnterFrameEvent _enterFrameEvent;
  ExitFrameEvent _exitFrameEvent;
  RenderEvent _renderEvent;
  

  RenderLoop() {
    
    _juggler = new Juggler();
    _stages = new List<Stage>();
    _renderTime = -1;

    _enterFrameEvent = new EnterFrameEvent(0);
    _exitFrameEvent = new ExitFrameEvent();
    _renderEvent = new RenderEvent();
    
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

    var deltaTime = currentTime - _renderTime;
    var deltaTimeSec = deltaTime / 1000.0;
    var currentTimeSec = currentTime / 1000.0;
    var invalidate = false;
    
    if (deltaTime >= 1) {
      _renderTime = currentTime;
      _enterFrameEvent._passedTime = deltaTimeSec;
      _EventStreamIndex.enterFrame._dispatchEvent(_enterFrameEvent);
      
      _juggler.advanceTime(deltaTimeSec);

      for(int i = 0; i < _stages.length; i++) {
        _stages[i].juggler.advanceTime(deltaTimeSec);
      }
      
      for(int i = 0; i < _stages.length; i++) {
        invalidate = invalidate || _stages[i]._invalidate;
      }
      
      if (invalidate) {
        _EventStreamIndex.render._dispatchEvent(_renderEvent);
      }
      
      for(int i = 0; i < _stages.length; i++) {
        _stages[i]._invalidate = false;
        _stages[i].materialize(currentTimeSec, deltaTimeSec);
      }
      
      _EventStreamIndex.exitFrame._dispatchEvent(_exitFrameEvent);
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
