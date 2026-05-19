import 'package:flutter/foundation.dart';

@immutable
class RecentConversion {
  const RecentConversion({
    required this.categoryId,
    required this.inputValue,
    required this.fromUnitId,
    required this.toUnitId,
    required this.result,
    required this.timestampMillis,
  });

  final String categoryId;
  final double inputValue;
  final String fromUnitId;
  final String toUnitId;
  final double result;
  final int timestampMillis;

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'inputValue': inputValue,
        'fromUnitId': fromUnitId,
        'toUnitId': toUnitId,
        'result': result,
        'timestampMillis': timestampMillis,
      };

  static RecentConversion? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final c = json['categoryId'] as String?;
    final f = json['fromUnitId'] as String?;
    final t = json['toUnitId'] as String?;
    final ts = json['timestampMillis'] as int?;
    final input = (json['inputValue'] as num?)?.toDouble();
    final res = (json['result'] as num?)?.toDouble();
    if (c == null || f == null || t == null || ts == null || input == null || res == null) {
      return null;
    }
    return RecentConversion(
      categoryId: c,
      inputValue: input,
      fromUnitId: f,
      toUnitId: t,
      result: res,
      timestampMillis: ts,
    );
  }
}
