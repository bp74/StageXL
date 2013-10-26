library example09;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

Stage stageBackground;
Stage stageForeground;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main() {

  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var canvasBackground = html.querySelector('#stageBackground');
  var canvasForeground = html.querySelector('#stageForeground');

  stageBackground = new Stage("stageBackground", canvasBackground);
  stageForeground = new Stage("stageForeground", canvasForeground);

  renderLoop = new RenderLoop();
  renderLoop.addStage(stageBackground);
  renderLoop.addStage(stageForeground);


  // The Particle Emitter was moved to the StageXL_Particle package.
  // Please check the example in this package.

  // ToDo: create a new example for another StageXL feature.
}



