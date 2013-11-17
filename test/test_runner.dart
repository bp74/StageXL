import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'display/bitmap_data_test.dart' as bitmap_data_test;
import 'geom/vector_test.dart' as vector_test;
import 'util/spritesheet_test.dart' as spritesheet_test;

void main() {
  useHtmlEnhancedConfiguration();

  group('BitmapData tests', bitmap_data_test.main);
  group('Vector tests', vector_test.main);
  group('Spritesheet tests', spritesheet_test.main);
}