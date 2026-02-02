class DashboardData {
  final int usersCount;
  final int rolesCount;
  final int eventsCount;
  final int absencesCount;
  final List<String> weeks;
  final List<int> presentTrend;
  final List<int> absentTrend;

  DashboardData({
    required this.usersCount,
    required this.rolesCount,
    required this.eventsCount,
    required this.absencesCount,
    required this.weeks,
    required this.presentTrend,
    required this.absentTrend,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      usersCount: json['usersCount'],
      rolesCount: json['rolesCount'],
      eventsCount: json['eventsCount'],
      absencesCount: json['absencesCount'],
      weeks: List<String>.from(json['weeks']),
      presentTrend: List<int>.from(json['presentTrend']),
      absentTrend: List<int>.from(json['absentTrend']),
    );
  }
}