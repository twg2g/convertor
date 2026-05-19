double _toCelsius(double value, String from) {
  switch (from) {
    case 'celsius':
      return value;
    case 'fahrenheit':
      return (value - 32) * 5 / 9;
    case 'kelvin':
      return value - 273.15;
    default:
      throw ArgumentError('Unknown temperature unit: $from');
  }
}

double _fromCelsius(double celsius, String to) {
  switch (to) {
    case 'celsius':
      return celsius;
    case 'fahrenheit':
      return celsius * 9 / 5 + 32;
    case 'kelvin':
      return celsius + 273.15;
    default:
      throw ArgumentError('Unknown temperature unit: $to');
  }
}

double convertTemperature(double value, String fromUnitId, String toUnitId) {
  if (fromUnitId == toUnitId) return value;
  return _fromCelsius(_toCelsius(value, fromUnitId), toUnitId);
}
