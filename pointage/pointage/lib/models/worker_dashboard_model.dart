class WorkerDashboardModel {
  final int daysPresent;
  final int totalWorkedHours;
  final int totalTasks;
  final int completedTasks;
  final int performancePercentage;

  WorkerDashboardModel({
    required this.daysPresent,
    required this.totalWorkedHours,
    required this.totalTasks,
    required this.completedTasks,
    required this.performancePercentage,
  });

  factory WorkerDashboardModel.fromJson(Map<String, dynamic> json) {
    return WorkerDashboardModel(
      daysPresent: json['daysPresent'] ?? 0,
      totalWorkedHours: json['totalWorkedHours'] ?? 0,
      totalTasks: json['totalTasks'] ?? 0,
      completedTasks: json['completedTasks'] ?? 0,
      performancePercentage:
          (json['performancePercentage'] is int)
              ? json['performancePercentage']
              : (json['performancePercentage'] ?? 0).toDouble().toInt(),
    );
  }
}
