import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'display/bitmap_data_test.dart' as bitmap_data_test;
import 'engine/render_texture_quad_test.dart' as render_texture_quad_test;
import 'events/events_test.dart' as events_test;
import 'geom/rectangle_test.dart' as rectangle_test;
import 'geom/point_test.dart' as point_test;
import 'geom/vector_test.dart' as vector_test;
import 'util/spritesheet_test.dart' as spritesheet_test;

void main() {
  useHtmlEnhancedConfiguration();

  group('BitmapData tests', bitmap_data_test.main);
  group('RenderTextureQuad tests', render_texture_quad_test.main);
  group('Events tests', events_test.main);
  group('Rectangle tests', rectangle_test.main);
  group('Point tests', point_test.main);
  group('Vector tests', vector_test.main);
  group('Spritesheet tests', spritesheet_test.main);
}
