class DailySummaryModel {
  final String day;
  final String hoursWorked;

  DailySummaryModel({required this.day, required this.hoursWorked});

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      day: json['day'] ?? '',
      hoursWorked: json['hoursWorked'] ?? '',
    );
  }
}

class MonthlySummaryModel {
  final List<DailySummaryModel> dailySummaries;
  final String totalWorkedTime;

  MonthlySummaryModel({
    required this.dailySummaries,
    required this.totalWorkedTime,
  });

  factory MonthlySummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlySummaryModel(
      dailySummaries:
          (json['dailySummaries'] as List? ?? [])
              .map((e) => DailySummaryModel.fromJson(e))
              .toList(),
      totalWorkedTime: json['totalWorkedTime'] ?? '',
    );
  }
}
