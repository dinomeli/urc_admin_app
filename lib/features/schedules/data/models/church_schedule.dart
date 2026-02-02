import 'package:flutter/foundation.dart';

import 'assignment.dart';  // اضافه کن
class ChurchSchedule {
  final int id;
  final DateTime serviceDate;
  final bool isConfirmed;
  final List<Assignment> assignments;

  ChurchSchedule({
    required this.id,
    required this.serviceDate,
    required this.isConfirmed,
    required this.assignments,
  });

  factory ChurchSchedule.fromJson(Map<String, dynamic> json) {
    return ChurchSchedule(
      id: json['id'] ?? 0,
      serviceDate: DateTime.parse(json['serviceDate'] ?? DateTime.now().toIso8601String()),
      isConfirmed: json['isConfirmed'] ?? false,
      assignments: (json['assignments'] as List<dynamic>? ?? [])
      .map((a) => Assignment.fromJson(a as Map<String, dynamic>))
      .toList(),
    );
  }
}