import 'dart:html' as html;
import 'package:stagexl/stagexl.dart';
import 'dart:math' as math;

void main() {
  var options = StageOptions()
    ..stageAlign = StageAlign.TOP_LEFT
    ..stageScaleMode = StageScaleMode.NO_SCALE
    ..renderEngine = RenderEngine.WebGL;

  var canvas = html.querySelector('#stage');
  var stage = Stage(canvas, width: 990, height: 620, options: options);
  var renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  var bitmapData = BitmapData(100, 100, Color.Red);
  var bitmap = Bitmap(bitmapData);
  bitmap.x = 100;
  bitmap.y = 100;
  bitmap.rotation = math.pi / 4;
  stage.addChild(bitmap);
}
