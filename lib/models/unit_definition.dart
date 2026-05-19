import 'package:flutter/foundation.dart';

@immutable
class UnitDefinition {
  const UnitDefinition({
    required this.id,
    required this.name,
    required this.symbol,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String symbol;
  final List<String> aliases;

  String get searchBlob {
    final parts = [id, name, symbol, ...aliases];
    return parts.join(' ').toLowerCase();
  }
}
