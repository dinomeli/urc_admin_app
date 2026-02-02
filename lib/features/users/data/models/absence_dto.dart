class AbsenceDto {
  final int id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final DateTime createdAt;

  AbsenceDto({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.createdAt,
  });

  factory AbsenceDto.fromJson(Map<String, dynamic> json) {
    return AbsenceDto(
      // استفاده از پارس امن برای جلوگیری از خطای Null to num
      id: json['id'] ?? json['Id'] ?? 0, 
      userId: (json['userId'] ?? json['UserId'] ?? "").toString(),
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : (json['StartDate'] != null ? DateTime.parse(json['StartDate']) : DateTime.now()),
      endDate: json['endDate'] != null 
          ? DateTime.parse(json['endDate']) 
          : (json['EndDate'] != null ? DateTime.parse(json['EndDate']) : DateTime.now()),
      reason: json['reason'] ?? json['Reason'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : (json['CreatedAt'] != null ? DateTime.parse(json['CreatedAt']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'reason': reason,
  };
}