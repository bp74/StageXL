library example01;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

Stage stage;
RenderLoop renderLoop;

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("stage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // load a Flump object and show it
  //------------------------------------------------------------------

  // ToDo: The Flump runtime has moved to the "StageXL_Flump" library.

  var textField = new TextField();
  textField.defaultTextFormat = new TextFormat("Arial", 20, Color.Red, bold:true);
  textField.text = "The Flump runtime has moved to the stagexl_flump library";
  textField.width = 700;
  textField.height= 100;
  textField.x = 20;
  textField.y = 20;
  stage.addChild(textField);
}
