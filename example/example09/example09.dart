library example09;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

Stage stageBackground;
Stage stageForeground;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main()
{

  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stageBackground = new Stage("stageBackground", html.document.query('#stageBackground'));
  stageForeground = new Stage("stageForeground", html.document.query('#stageForeground'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stageBackground);
  renderLoop.addStage(stageForeground);


  // The Particle Emitter was moved to the StageXL_Particle package.
  // Please check the example in this package.

  // ToDo: create a new example for another StageXL feature.
}



