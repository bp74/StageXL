import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';

import 'vector_test.dart' as vector_test;

void main() {
  useHtmlEnhancedConfiguration();

  group('Vector tests', vector_test.main);
}