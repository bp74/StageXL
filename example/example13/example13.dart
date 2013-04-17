library example01;

import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

void main() {

  // The Stage is the root of the display list.
  var canvas = html.query('#stage');
  var stage = new Stage('myStage', canvas);

  // The RenderLoop controls the flow of the program
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);
  
  // Load one image
  var resourceManager = new ResourceManager()
  ..addBitmapData("astronaut", "../common/images/Astronaut.jpg");

  resourceManager.load().then((result)
  {
    Bitmap image = new Bitmap(resourceManager.getBitmapData("astronaut"));
    
    // Create the MovieClip animation
    stage.addChild(new Astronaut(image));
  });
}

class Astronaut extends MovieClip
{
  Bitmap image;
  
  Astronaut(this.image)
  : super(null, 0, true/*loop*/, null) {
    
    image.off = true; // disabled
    
    // build the timeline animation
    timeline.addTween(TimelineTween.get(image)
        .wait(20) // hidden during 20 frames
        .to({"off":false}, 0) // enable
        .to({"x":200, "y":100, "rotation":0.3}, 30) // animate during 30 frames
        .wait(10) // wait 10 frames
        .to({"x":0, "rotation":0}, 5) // animate during 5 frames
        .to({"alpha":0}, 20) // fade out during 20 frames
        );
    
    // Note: using the timeline overrides the behavior of addChild/removeChild
    // and everything must be added through timeline.addTween. 
  }
}

