library example06;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {

  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  var stage = new Stage("myStage", html.document.query('#stage'));
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Draw a cloud with vectors
  //------------------------------------------------------------------

  var gradient = new GraphicsGradient.linear(230, 0, 370, 200)
    ..addColorStop(0, 0xFF8ED6FF)
    ..addColorStop(1, 0xFF004CB3);

  var sprite = new Sprite()
    ..useHandCursor = true
    ..addTo(stage);

  var shape = new Shape()
    ..x = 400
    ..y = 300
    ..pivotX = 278
    ..pivotY = 90
    ..addTo(sprite);

  shape.graphics
    ..beginPath()
    ..moveTo(170, 80)
    ..bezierCurveTo(130, 100, 130, 150, 230, 150)
    ..bezierCurveTo(250, 180, 320, 180, 340, 150)
    ..bezierCurveTo(420, 150, 420, 120, 390, 100)
    ..bezierCurveTo(430, 40, 370, 30, 340, 50)
    ..bezierCurveTo(320, 5, 250, 20, 250, 50)
    ..bezierCurveTo(200, 5, 150, 20, 170, 80)
    ..closePath()
    ..fillGradient(gradient)
    ..strokeColor(Color.Blue, 5);

  //------------------------------------------------------------------
  // Add some animation
  //------------------------------------------------------------------

  stage.juggler.tween(shape, 3.0, TransitionFunction.easeInOutBack)
    ..animate.scaleX.to(2.5)
    ..animate.scaleY.to(2.5)
    ..delay = 1.0;

  stage.juggler.tween(shape, 3.0, TransitionFunction.easeInOutBack)
    ..animate.scaleX.to(1.0)
    ..animate.scaleY.to(1.0)
    ..delay = 5.0;
}
