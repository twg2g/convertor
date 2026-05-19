String formatConverted(double? value, int decimalPlaces) {
  if (value == null || value.isNaN || value.isInfinite) return '—';
  return value.toStringAsFixed(decimalPlaces);
}

double? tryParseAmount(String raw) {
  final t = raw.trim().replaceAll(',', '.');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}
