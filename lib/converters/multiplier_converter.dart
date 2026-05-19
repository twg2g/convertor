double convertMultiplier(
  double value,
  String fromUnitId,
  String toUnitId,
  Map<String, double> unitToBase,
) {
  final from = unitToBase[fromUnitId];
  final to = unitToBase[toUnitId];
  if (from == null || to == null || to == 0) {
    throw ArgumentError('Unknown unit or invalid base map');
  }
  return value * from / to;
}
