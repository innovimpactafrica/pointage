import 'package:dio/dio.dart';
import 'package:pointage/models/TaskModel.dart';
import 'package:pointage/services/api_service.dart';

class TaskService {
  final Dio _dio = ApiService().dio;

  Future<List<TaskModel>> fetchTasksByExecutor(int executorId) async {
    final response = await _dio.get('/tasks/by-executor/$executorId');
    final data = response.data['content'] as List? ?? [];
    return data.map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    await _dio.put(
      '/tasks/$taskId/status',
      queryParameters: {'status': status},
    );
  }

  Future<TaskModel> fetchTaskDetail(int taskId) async {
    final response = await _dio.get('/tasks/$taskId');
    return TaskModel.fromJson(response.data);
  }
}
