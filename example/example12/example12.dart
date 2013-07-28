library example01;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var canvas = html.document.query('#stage');
  var stage = new Stage("stage", canvas);

  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------

  canvas.focus();

  var textField = new TextField();
  textField.defaultTextFormat = new TextFormat("Helvetica,Arial", 20, Color.Black);
  textField.text = "The Dart language is familiar and easy to learn. "
"It's class based and object oriented, without being dogmatic.\n\n";
  textField.type = TextFieldType.INPUT;
  textField.width = 400;
  textField.height= 300;
  textField.wordWrap = true;
  textField.multiline = true;
  textField.background = true;
  textField.backgroundColor = Color.Beige;
  textField.x = 20;
  textField.y = 20;

  stage.addChild(textField);
  stage.focus = textField;
}
