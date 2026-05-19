import 'package:flutter_test/flutter_test.dart';
import 'package:universal_converter/converters/category_engine.dart';
import 'package:universal_converter/converters/multiplier_converter.dart';
import 'package:universal_converter/converters/temperature_converter.dart';
import 'package:universal_converter/data/category_data.dart';

void main() {
  test('1 km to m', () {
    expect(convertMultiplier(1, 'kilometer', 'meter', lengthToMeter), 1000);
  });

  test('0 C to F', () {
    expect(convertTemperature(0, 'celsius', 'fahrenheit'), 32);
  });

  test('length mile to km', () {
    expect(convertCategorySync('length', 1, 'mile', 'kilometer'), closeTo(1.609344, 1e-5));
  });
}
