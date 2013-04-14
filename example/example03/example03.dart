library example03;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';

part 'world.dart';

Stage stage;
RenderLoop renderLoop;
ResourceManager resourceManager;

void main() {
  
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  stage = new Stage("myStage", html.document.query('#stage'));

  renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  BitmapData.defaultLoadOptions.webp = true;
  
  resourceManager = new ResourceManager()
    ..addBitmapData("house", "../common/images/House.png")
    ..addBitmapData("sun", "../common/images/Sun.png")
    ..addBitmapData("tree", "../common/images/Tree.png");

  resourceManager.load().then((_) => drawWorlds());
}

void drawWorlds() {
    
  // Place the World on the stage

  var world = new World(resourceManager);
  world.x = 10;
  world.y = 20;
  world.filters = [new ColorMatrixFilter.grayscale(), new GlowFilter(Color.Magenta, 1.0, 20, 20)];
  world.applyCache(-10, -10, 185, 190);
  world.addTo(stage);
  
  // Only one World? We want many worlds ....
  
  num posX = 20;
  for(int i = 0; i < 5; i++) {
    
    var otherWorld = new World(resourceManager);
    otherWorld.scaleX = 1.0 - i * 0.1;
    otherWorld.scaleY = 1.0 - i * 0.1;
    otherWorld.x = posX;
    otherWorld.y = 500 - otherWorld.height;
    otherWorld.filters = [new GlowFilter(Color.Green, 1.0, 20, 20)];
    otherWorld.applyCache(-10, -10, 185, 190);
    otherWorld.addTo(stage);

    posX = posX + otherWorld.width + 10;
  }
}
