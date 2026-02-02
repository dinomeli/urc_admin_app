import 'package:json_annotation/json_annotation.dart';

part 'calendar_event_dto.g.dart';

@JsonSerializable()
class CalendarEventDto {
  final int id;
  final String title;
  final String start;
  final String? end;
  final String color;
  final ExtendedProps extendedProps;
DateTime get startDate => DateTime.parse(start);
  CalendarEventDto({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    required this.color,
    required this.extendedProps,
  });

  factory CalendarEventDto.fromJson(Map<String, dynamic> json) => _$CalendarEventDtoFromJson(json);
}

@JsonSerializable()
class ExtendedProps {
  final bool isConfirmed;
  final int assignmentsCount;
  final String description;

  ExtendedProps({
    required this.isConfirmed,
    required this.assignmentsCount,
    required this.description,
  });

  factory ExtendedProps.fromJson(Map<String, dynamic> json) => _$ExtendedPropsFromJson(json);
}