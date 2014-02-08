library example02;

import 'dart:html' as html;
//import 'package:stagexl/stagexl.dart';
import '../lib/stagexl.dart';

void main() {

  var canvas = html.querySelector('#stage');
  var stage = new Stage(canvas, webGL: true);
  var renderLoop = new RenderLoop();
  renderLoop.addStage(stage);

  //var bitmap = new Bitmap(new BitmapData(500,400, false, Color.Gray));
  //stage.addChild(bitmap);

  var resourceManager = new ResourceManager()
    ..addBitmapData("house", "images/House.png")
    ..addBitmapData("sun", "images/Sun.png")
    ..addBitmapData("tree", "images/Tree.png");

  resourceManager.load().then((result) {

    var colorMatrixFilter = new ColorMatrixFilter.identity();
    var world = new Sprite();

    //var fragment = new Fragment(world);
    //fragment.alpha = 0.5;
    //fragment.addTo(stage);
    world.addTo(stage);
    //world.alpha = 0.5;
    world.filters= [colorMatrixFilter];
    //world.mask = new Mask.rectangle(250, 140, 100, 150);

    var sun = new Bitmap(resourceManager.getBitmapData("sun"));
    sun.x = 260;
    sun.y = 140;
    sun.addTo(world);
    var house = new Bitmap(resourceManager.getBitmapData("house"));
    house.x = 250;
    house.y = 200;
    house.addTo(world);
    var tree = new Bitmap(resourceManager.getBitmapData("tree"));
    tree.x = 300;
    tree.y = 200;
    tree.addTo(world);

    stage.juggler.transition(-1, 1, 3, (x) => x, (value) {
      world.filters= [new ColorMatrixFilter.adjust(saturation: value)];
    });

    //world.applyCache(250, 140, 200, 200, debugBorder: true);

  }).catchError((e) => print(e));
}
