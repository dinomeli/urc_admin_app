// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventDto _$CalendarEventDtoFromJson(Map<String, dynamic> json) =>
    CalendarEventDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      start: json['start'] as String,
      end: json['end'] as String?,
      color: json['color'] as String,
      extendedProps: ExtendedProps.fromJson(
        json['extendedProps'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$CalendarEventDtoToJson(CalendarEventDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'start': instance.start,
      'end': instance.end,
      'color': instance.color,
      'extendedProps': instance.extendedProps,
    };

ExtendedProps _$ExtendedPropsFromJson(Map<String, dynamic> json) =>
    ExtendedProps(
      isConfirmed: json['isConfirmed'] as bool,
      assignmentsCount: (json['assignmentsCount'] as num).toInt(),
      description: json['description'] as String,
    );

Map<String, dynamic> _$ExtendedPropsToJson(ExtendedProps instance) =>
    <String, dynamic>{
      'isConfirmed': instance.isConfirmed,
      'assignmentsCount': instance.assignmentsCount,
      'description': instance.description,
    };
