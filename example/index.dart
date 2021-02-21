import 'dart:html' as html;
import 'dart:math' as math;

import 'package:stagexl/stagexl.dart';

void main() {
  final options = StageOptions()
    ..stageAlign = StageAlign.TOP_LEFT
    ..stageScaleMode = StageScaleMode.NO_SCALE
    ..renderEngine = RenderEngine.WebGL;

  final canvas = html.querySelector('#stage') as html.CanvasElement;
  final stage = Stage(canvas, width: 990, height: 620, options: options);
  final renderLoop = RenderLoop();
  renderLoop.addStage(stage);

  final bitmapData = BitmapData(100, 100, Color.Red);
  final bitmap = Bitmap(bitmapData);
  bitmap.x = 100;
  bitmap.y = 100;
  bitmap.rotation = math.pi / 4;
  stage.addChild(bitmap);
}
