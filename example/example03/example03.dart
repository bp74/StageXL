library example03;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:dartflash/dartflash.dart';

part 'world.dart';

void main()
{
  //------------------------------------------------------------------
  // Initialize the Display List
  //------------------------------------------------------------------

  Stage stage = new Stage("myStage", html.document.query('#stage'));

  RenderLoop renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //------------------------------------------------------------------
  // Use the Resource class to load some Bitmaps
  //------------------------------------------------------------------

  var resourceManager = new ResourceManager()
    ..addBitmapData("house", "../common/images/House.png")
    ..addBitmapData("sun", "../common/images/Sun.png")
    ..addBitmapData("tree", "../common/images/Tree.png");

  resourceManager.load().then((result)
  {
    // Place the World on the stage

    World world = new World(resourceManager);
    world.x = 10;
    world.y = 20;
    stage.addChild(world);

    // Only one World? We want many worlds ....

    num posX = 0;

    for(int i = 0; i < 5; i++)
    {
      World otherWorld = new World(resourceManager);
      otherWorld.scaleX = 1.0 - i * 0.1;
      otherWorld.scaleY = 1.0 - i * 0.1;
      otherWorld.x = posX;
      otherWorld.y = 500 - otherWorld.height;
      stage.addChild(otherWorld);

      posX = posX + otherWorld.width + 10;
    }

  });

}
