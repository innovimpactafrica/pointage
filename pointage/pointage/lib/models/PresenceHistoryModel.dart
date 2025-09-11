class PresenceLog {
  final int id;
  final List<int> checkInTime;
  final List<int> checkOutTime;

  PresenceLog({
    required this.id,
    required this.checkInTime,
    required this.checkOutTime,
  });

  factory PresenceLog.fromJson(Map<String, dynamic> json) {
    return PresenceLog(
      id: json['id'],
      checkInTime: List<int>.from(json['checkInTime'] ?? []),
      checkOutTime: List<int>.from(json['checkOutTime'] ?? []),
    );
  }

  String get formattedCheckIn => _formatTime(checkInTime);
  String get formattedCheckOut => _formatTime(checkOutTime);

  static String _formatTime(List<int> time) {
    if (time.length < 3) return '--:--';
    final h = time[0].toString().padLeft(2, '0');
    final m = time[1].toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class PresenceHistoryModel {
  final List<PresenceLog> logs;
  final String totalWorkedTime;

  PresenceHistoryModel({required this.logs, required this.totalWorkedTime});

  factory PresenceHistoryModel.fromJson(Map<String, dynamic> json) {
    return PresenceHistoryModel(
      logs:
          (json['logs'] as List? ?? [])
              .map((e) => PresenceLog.fromJson(e))
              .toList(),
      totalWorkedTime: json['totalWorkedTime'] ?? '',
    );
  }
}
