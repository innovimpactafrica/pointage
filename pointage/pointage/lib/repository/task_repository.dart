import 'package:pointage/services/task_service.dart';
import '../models/TaskModel.dart';

class TaskRepository {
  final TaskService taskService;
  TaskRepository({required this.taskService});

  Future<List<TaskModel>> getTasksByExecutor(int executorId) {
    return taskService.fetchTasksByExecutor(executorId);
  }

  Future<void> updateTaskStatus(int taskId, String status) {
    return taskService.updateTaskStatus(taskId, status);
  }

  Future<TaskModel> getTaskDetail(int taskId) {
    return taskService.fetchTaskDetail(taskId);
  }
}
