# Getting started with dartflash

Learn the basic steps to build an application with dartflash.

## Sample Application

The following code will show you how to initialize the main drawing area (Stage) and how to put an image (BitmapData) to the screen. The image will be rotated, scaled and placed in the coordinate system of the Stage.

### HTML Code

    <canvas id="stageCanvas" width="320" height="240"></canvas>

### Dart Code

    // the Stage is a wrapper over the HTML canvas element.
    Stage stage = new Stage('myStage', html.query('#stageCanvas'));

    // the RenderLoop controls the flow of the program
    RenderLoop renderLoop = new RenderLoop();
    renderLoop.addStage(stage);

    // start loading an image (BitmapData) and continue when finished
    Future<BitmapData> future = BitmapData.loadImage('Flower.png');
    future.then((BitmapData bitmapData)
    {
      Bitmap bitmap = new Bitmap(bitmapData);
      bitmap.scaleX = bitmap.scaleY = 0.5;
      bitmap.rotation = PI / 8;
      bitmap.x = 50;
      bitmap.y = 30;
      stage.addChild(bitmap);
    });

### Other Samples

The example folder in this repository contains more advanced demos and applications. Please start with the demos and learn about the basic building blocks of dartflash. If you have some experience with the Adobe Flash API you will be pleasantly surprised :) 

## Package Import

Add the dartflash depedency to your pubspec.yaml ...

    name: BestGameEver
    description: the best game on the web!
    dependencies: 
      dartflash: { git: https://github.com/bp74/dartflash.git }

... then import the library in your Dart code.

    import 'package:dartflash/dartflash.dart';

## Resources

Visit our main website [www.dartflash.com](http://www.dartflash.com) to get more information about dartflash.

* [API Reference](http://www.dartflash.com)
* [Articles and Tutorials](http://www.dartflash.com)
* [Demos](http://www.dartflash.com)
* [FAQ](http://www.dartflash.com)

Other related websites:

* [dartflash blog](http://blog.dartflash.com)
