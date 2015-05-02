part of stagexl.display;

/// The options used by the [Stage] constructor to setup the stage.

class StageOptions {

  RenderEngine renderEngine = RenderEngine.WebGL;

  StageRenderMode stageRenderMode = StageRenderMode.AUTO;

  StageScaleMode stageScaleMode = StageScaleMode.SHOW_ALL;

  StageAlign stageAlign = StageAlign.NONE;

  int backgroundColor = Color.White;

  bool transparent = false;

  bool antialias = false;

  num maxPixelRatio = 5.0;
}
