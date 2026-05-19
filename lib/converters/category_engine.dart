import '../data/category_data.dart';
import '../models/conversion_category.dart';
import 'multiplier_converter.dart';
import 'temperature_converter.dart';

double convertCategorySync(
  String categoryId,
  double value,
  String fromUnitId,
  String toUnitId,
) {
  final cat = categoryById(categoryId);
  if (cat == null) throw ArgumentError('Unknown category: $categoryId');
  switch (cat.kind) {
    case ConversionCategoryKind.multiplier:
      if (categoryId == 'length') {
        return convertMultiplier(value, fromUnitId, toUnitId, lengthToMeter);
      }
      if (categoryId == 'weight') {
        return convertMultiplier(value, fromUnitId, toUnitId, weightToKg);
      }
      throw UnsupportedError('Multiplier category not wired: $categoryId');
    case ConversionCategoryKind.temperature:
      return convertTemperature(value, fromUnitId, toUnitId);
    case ConversionCategoryKind.currency:
      throw StateError('Use CurrencyRatesRepository for currency');
  }
}
