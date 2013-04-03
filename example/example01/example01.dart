library example01;

import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {

  // The Stage is the root of the display list.
  var canvas = html.query('#stage');
  var stage = new Stage('myStage', canvas);

  // The RenderLoop controls the flow of the program
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var circle1 = new Shape();
  circle1.graphics.rect(0, 0, 80, 80);
  circle1.graphics.fillColor(0xFF0000FF);  
  circle1.x = 50;
  circle1.y = 120;
  stage.addChild(circle1);
  
  var circle2 = new Shape();
  circle2.graphics.rect(0, 0, 80, 80);
  circle2.graphics.fillColor(0xFF00FF00);
  circle2.rotation = PI / 4;
  circle2.x = 180;
  circle2.y = 180;
  stage.addChild(circle2);
  
  stage.addEventListener(Event.ENTER_FRAME, (Event e ) {
    print(circle2.hitTestPoint(stage.mouseX, stage.mouseY, true));
  });
}

class Painting extends DisplayObjectContainer {

  final List<int> colors = [Color.Red, Color.Green, Color.Blue, Color.Brown];

  Painting() {

    // The background of the painting is 400x300 pixels in size and  
    // filled wit the color 'BlanchedAlmond'.
    var background = new BitmapData(400, 300, false, Color.BlanchedAlmond);
    var backgroundBitmap = new Bitmap(background);
    addChild(backgroundBitmap);

    // Draw 4 boxes. Each box is a little bit shifted to the 
    // bottom right relative to it's predecessor.
    for(var i = 0; i < colors.length; i++) {
      var box = new BitmapData(100, 100, false, colors[i]);
      var boxBitmap = new Bitmap(box);
      boxBitmap.x = 80 + i * 50;
      boxBitmap.y = 60 + i * 30;
      addChild(boxBitmap);
    }
  }
}


