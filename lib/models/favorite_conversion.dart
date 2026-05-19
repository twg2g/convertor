import 'package:flutter/foundation.dart';

@immutable
class FavoriteConversion {
  const FavoriteConversion({
    required this.categoryId,
    required this.fromUnitId,
    required this.toUnitId,
    required this.createdAtMillis,
  });

  final String categoryId;
  final String fromUnitId;
  final String toUnitId;
  final int createdAtMillis;

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'fromUnitId': fromUnitId,
        'toUnitId': toUnitId,
        'createdAtMillis': createdAtMillis,
      };

  static FavoriteConversion? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final c = json['categoryId'] as String?;
    final f = json['fromUnitId'] as String?;
    final t = json['toUnitId'] as String?;
    final m = json['createdAtMillis'] as int?;
    if (c == null || f == null || t == null || m == null) return null;
    return FavoriteConversion(
      categoryId: c,
      fromUnitId: f,
      toUnitId: t,
      createdAtMillis: m,
    );
  }
}
