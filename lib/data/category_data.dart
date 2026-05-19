import '../models/conversion_category.dart';
import '../models/unit_definition.dart';

const categories = <ConversionCategory>[
  ConversionCategory(
    id: 'currency',
    title: 'Currency',
    iconName: 'payments',
    kind: ConversionCategoryKind.currency,
  ),
  ConversionCategory(
    id: 'length',
    title: 'Length',
    iconName: 'straighten',
    kind: ConversionCategoryKind.multiplier,
  ),
  ConversionCategory(
    id: 'weight',
    title: 'Weight',
    iconName: 'scale',
    kind: ConversionCategoryKind.multiplier,
  ),
  ConversionCategory(
    id: 'temperature',
    title: 'Temperature',
    iconName: 'thermostat',
    kind: ConversionCategoryKind.temperature,
  ),
];

ConversionCategory? categoryById(String id) {
  for (final c in categories) {
    if (c.id == id) return c;
  }
  return null;
}

const lengthToMeter = <String, double>{
  'meter': 1,
  'kilometer': 1000,
  'centimeter': 0.01,
  'millimeter': 0.001,
  'mile': 1609.344,
  'yard': 0.9144,
  'foot': 0.3048,
  'inch': 0.0254,
};

const weightToKg = <String, double>{
  'kilogram': 1,
  'gram': 0.001,
  'milligram': 1e-6,
  'pound': 0.45359237,
  'ounce': 0.028349523125,
  'stone': 6.35029318,
  'metric_ton': 1000,
};

const lengthUnits = <UnitDefinition>[
  UnitDefinition(id: 'meter', name: 'Meter', symbol: 'm', aliases: ['metre']),
  UnitDefinition(id: 'kilometer', name: 'Kilometer', symbol: 'km'),
  UnitDefinition(id: 'centimeter', name: 'Centimeter', symbol: 'cm'),
  UnitDefinition(id: 'millimeter', name: 'Millimeter', symbol: 'mm'),
  UnitDefinition(id: 'mile', name: 'Mile', symbol: 'mi'),
  UnitDefinition(id: 'yard', name: 'Yard', symbol: 'yd'),
  UnitDefinition(id: 'foot', name: 'Foot', symbol: 'ft', aliases: ['feet']),
  UnitDefinition(id: 'inch', name: 'Inch', symbol: 'in'),
];

const weightUnits = <UnitDefinition>[
  UnitDefinition(id: 'kilogram', name: 'Kilogram', symbol: 'kg', aliases: ['kilo']),
  UnitDefinition(id: 'gram', name: 'Gram', symbol: 'g'),
  UnitDefinition(id: 'milligram', name: 'Milligram', symbol: 'mg'),
  UnitDefinition(id: 'pound', name: 'Pound', symbol: 'lb', aliases: ['lbs']),
  UnitDefinition(id: 'ounce', name: 'Ounce', symbol: 'oz'),
  UnitDefinition(id: 'stone', name: 'Stone', symbol: 'st'),
  UnitDefinition(id: 'metric_ton', name: 'Metric ton', symbol: 't', aliases: ['tonne']),
];

const temperatureUnits = <UnitDefinition>[
  UnitDefinition(id: 'celsius', name: 'Celsius', symbol: '°C', aliases: ['c']),
  UnitDefinition(id: 'fahrenheit', name: 'Fahrenheit', symbol: '°F', aliases: ['f']),
  UnitDefinition(id: 'kelvin', name: 'Kelvin', symbol: 'K'),
];

const currencyUnits = <UnitDefinition>[
  UnitDefinition(id: 'USD', name: 'US Dollar', symbol: r'$', aliases: ['usd']),
  UnitDefinition(id: 'EUR', name: 'Euro', symbol: '€', aliases: ['euro']),
  UnitDefinition(id: 'GBP', name: 'British Pound', symbol: '£'),
  UnitDefinition(id: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  UnitDefinition(id: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
  UnitDefinition(id: 'CNY', name: 'Chinese Yuan', symbol: '¥', aliases: ['rmb']),
  UnitDefinition(id: 'ZMW', name: 'Zambian Kwacha', symbol: 'ZK', aliases: ['kwacha']),
  UnitDefinition(id: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),
  UnitDefinition(id: 'AUD', name: 'Australian Dollar', symbol: r'A$'),
  UnitDefinition(id: 'INR', name: 'Indian Rupee', symbol: '₹'),
  UnitDefinition(id: 'BRL', name: 'Brazilian Real', symbol: r'R$'),
  UnitDefinition(id: 'ZAR', name: 'South African Rand', symbol: 'R'),
  UnitDefinition(id: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
  UnitDefinition(id: 'KES', name: 'Kenyan Shilling', symbol: 'KSh'),
];

List<UnitDefinition> unitsForCategory(String categoryId) {
  switch (categoryId) {
    case 'length':
      return lengthUnits;
    case 'weight':
      return weightUnits;
    case 'temperature':
      return temperatureUnits;
    case 'currency':
      return currencyUnits;
    default:
      return const [];
  }
}

UnitDefinition? unitById(String categoryId, String unitId) {
  for (final u in unitsForCategory(categoryId)) {
    if (u.id == unitId) return u;
  }
  return null;
}
