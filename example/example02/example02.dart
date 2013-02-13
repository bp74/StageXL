library example02;

import 'dart:async';
import 'dart:math';
import 'dart:html' as html;
import 'package:dartflash/dartflash.dart';

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

  // we cannot use embedded Bitmaps like we do it in a SWF file.
  // but the library provides an easy way to load resources.

  var resourceManager = new ResourceManager()
    ..addImage("house", "../common/images/House.png")
    ..addImage("sun", "../common/images/Sun.png")
    ..addImage("tree", "../common/images/Tree.png");

  resourceManager.load().then((result)
  {
    Bitmap house = new Bitmap(resourceManager.getBitmapData("house"));
    house.x = 200;
    house.y = 200;
    stage.addChild(house);

    Bitmap tree = new Bitmap(resourceManager.getBitmapData("tree"));
    tree.x = 330;
    tree.y = 200;
    stage.addChild(tree);

    Bitmap sun = new Bitmap(resourceManager.getBitmapData("sun"));
    sun.x = 250;
    sun.y = 50;
    stage.addChild(sun);
  });
}
