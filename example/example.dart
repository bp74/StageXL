library example02;

import 'dart:html' as html;
import 'dart:math' as math;
//import 'package:stagexl/stagexl.dart';
import '../lib/stagexl.dart';

void main() {

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, webGL: true, color: Color.DarkBlue);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  var resourceManager = new ResourceManager()
    ..addBitmapData("house", "images/House.png")
    ..addBitmapData("sun", "images/Sun.png")
    ..addBitmapData("tree", "images/Tree.png");

  resourceManager.load().then((result) {

    var colorMatrixFilter = new ColorMatrixFilter.grayscale();
    //var colorMatrixFilter = new ColorMatrixFilter.invert();
    //var colorMatrixFilter = new ColorMatrixFilter.identity();
    //var colorMatrixFilter = new ColorMatrixFilter.adjust(contrast: 1);
    var blurFilter = new BlurFilter(4, 4);
    var dropShadowFilter = new DropShadowFilter(10, math.PI / 4, Color.Black,  1.0, 5, 5);

    var world = new Sprite();
    world.addTo(stage);
    //world.alpha = 0.5;
    //world.filters= [colorMatrixFilter];
    //world.filters= [blurFilter];
    world.filters= [colorMatrixFilter, blurFilter];
    //world.filters= [colorMatrixFilter, dropShadowFilter];

    /*
    stage.juggler.transition(-1, 1, 10, (x) => x, (value) {
      world.filters= [new ColorMatrixFilter.adjust(hue: value)];
    });
    */

    var sun = new Bitmap(resourceManager.getBitmapData("sun"));
    sun.pivotX = 65;
    sun.pivotY = 62;
    sun.x = 320;
    sun.y = 200;
    sun.addTo(world);
    var house = new Bitmap(resourceManager.getBitmapData("house"));
    house.x = 250;
    house.y = 200;
    house.addTo(world);
    var tree = new Bitmap(resourceManager.getBitmapData("tree"));
    tree.x = 300;
    tree.y = 200;
    tree.addTo(world);

    stage.juggler.tween(sun, 60.0, (x) => x).animate.rotation.to(20 * math.PI);


   // world.applyCache(250, 140, 200, 200, debugBorder: true);

  }).catchError((e) => print(e));
}
