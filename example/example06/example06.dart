library example06;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Draw a cloud with vectors
  //------------------------------------------------------------------

  var gradient = new GraphicsGradient.linear(230, 0, 370, 200);
  gradient.addColorStop(0, 0xFF8ED6FF);
  gradient.addColorStop(1, 0xFF004CB3);

  Sprite sprite = new Sprite();
  sprite.useHandCursor = true;
  stage.addChild(sprite);

  Shape shape = new Shape();
  shape.pivotX = 278;
  shape.pivotY = 90;
  shape.x = 400;
  shape.y = 300;
  sprite.addChild(shape);

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

  Tween tween1 = new Tween(shape, 3.0, TransitionFunction.easeInOutBack)
    ..animate.scaleX.to(2.5)
    ..animate.scaleY.to(2.5)
    ..delay = 1.0;

  Tween tween2 = new Tween(shape, 3.0, TransitionFunction.easeInOutBack)
    ..animate.scaleX.to(1.0)
    ..animate.scaleY.to(1.0)
    ..delay = 5.0;

  renderLoop.juggler.add(tween1);
  renderLoop.juggler.add(tween2);
}
