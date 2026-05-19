import 'package:flutter/foundation.dart';

enum ConversionCategoryKind { multiplier, temperature, currency }

@immutable
class ConversionCategory {
  const ConversionCategory({
    required this.id,
    required this.title,
    required this.iconName,
    required this.kind,
  });

  final String id;
  final String title;
  final String iconName;
  final ConversionCategoryKind kind;
}
