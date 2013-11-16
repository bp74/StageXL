import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'vector_test.dart' as vector_test;
import 'util/spritesheet_test.dart' as spritesheet_test;

void main() {
  useHtmlEnhancedConfiguration();

  group('Vector tests', vector_test.main);
  group('Spritesheet tests', spritesheet_test.main);
}