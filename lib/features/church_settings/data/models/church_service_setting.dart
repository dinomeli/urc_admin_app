import 'package:flutter/material.dart';
class ChurchServiceSetting {
  final int? id;               // nullable
  final int? churchId;         // nullable (برای امنیت)
  final String? churchName;
  final String? programType;
  final DateTime? serviceDate;
  final TimeOfDay? serviceStartTime;
  final bool isActive;

  ChurchServiceSetting({
    this.id,
    this.churchId,
    this.churchName,
    this.programType,
    this.serviceDate,
    this.serviceStartTime,
    this.isActive = true,
  });

  factory ChurchServiceSetting.fromJson(Map<String, dynamic> json) {
    return ChurchServiceSetting(
      id: json['Id'] as int?,
      churchId: json['ChurchId'] as int?,
      churchName: json['ChurchName'] as String?,
      programType: json['ProgramType'] as String?,
      serviceDate: json['ServiceDate'] != null 
          ? DateTime.tryParse(json['ServiceDate'].toString()) 
          : null,
      serviceStartTime: json['ServiceStartTime'] != null
          ? _parseTime(json['ServiceStartTime'])
          : null,
      isActive: json['IsActive'] as bool? ?? true,
    );
  }

  static TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null) return null;
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ChurchId': churchId,
      'ProgramType': programType,
      'ServiceDate': serviceDate?.toIso8601String().split('T')[0],
      'ServiceStartTime': serviceStartTime != null
          ? '${serviceStartTime!.hour.toString().padLeft(2, '0')}:${serviceStartTime!.minute.toString().padLeft(2, '0')}:00'
          : null,
      'IsActive': isActive,
    };
  }
}