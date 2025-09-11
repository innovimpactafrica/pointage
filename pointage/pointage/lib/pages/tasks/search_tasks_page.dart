import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/HexColor.dart';
import '../../models/TaskModel.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../repository/task_repository.dart';
import '../../services/task_service.dart';
import '../../services/AuthService.dart';
import '../../models/UserModel.dart';

class SearchTasksPage extends StatefulWidget {
  const SearchTasksPage({Key? key}) : super(key: key);

  @override
  State<SearchTasksPage> createState() => _SearchTasksPageState();
}

class _SearchTasksPageState extends State<SearchTasksPage> {
  final TextEditingController _searchController = TextEditingController();
  final _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.connectedUser();
      if (userData != null) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<TaskModel> _filterTasksBySearch(List<TaskModel> tasks, String query) {
    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  String _formatTaskDate(TaskModel task) {
    if (task.startDate != null && task.endDate != null) {
      final start = task.startDate!;
      final end = task.endDate!;
      String startStr =
          "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}";
      String endStr =
          "${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}";
      return "$startStr - $endStr";
    }
    return '';
  }

  String _mapStatus(String status) {
    switch (status) {
      case 'TODO':
        return 'En attente';
      case 'IN_PROGRESS':
        return 'En cours';
      case 'DONE':
        return 'Terminée';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'DONE':
        return const Color(0xFFB7F5C5);
      default:
        return const Color(0xFFBFC5D2);
    }
  }

  String _mapPriority(String priority) {
    switch (priority) {
      case 'HIGH':
        return 'Haute';
      case 'MEDIUM':
        return 'Moyenne';
      case 'LOW':
        return 'Faible';
      default:
        return priority;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return const Color(0xFFFF3B30);
      case 'MEDIUM':
        return const Color(0xFFFFA726);
      case 'LOW':
        return const Color(0xFF2ECC71);
      default:
        return const Color(0xFF8A98A8);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur: Utilisateur non trouvé')),
      );
    }

    return Scaffold(
      backgroundColor: HexColor('#F1F2F6'),
      appBar: AppBar(
        backgroundColor: HexColor('#1A365D'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Rechercher des tâches',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: const EdgeInsets.all(16),
            color: HexColor('#1A365D'),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Rechercher une tâche...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  suffixIcon: Icon(Icons.clear, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Résultats
          Expanded(
            child: BlocProvider<TaskBloc>(
              create:
                  (_) => TaskBloc(
                    taskRepository: TaskRepository(taskService: TaskService()),
                  )..add(LoadTasksEvent(_currentUser!.id)),
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (state is TaskLoaded) {
                    final filteredTasks = _filterTasksBySearch(
                      state.tasks,
                      _searchQuery,
                    );

                    if (_searchQuery.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tapez pour rechercher des tâches',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Recherchez par titre ou description',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune tâche trouvée',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Aucun résultat pour "$_searchQuery"',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('#FF5C02'),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Effacer la recherche',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        // En-tête des résultats
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Text(
                                '${filteredTasks.length} résultat${filteredTasks.length > 1 ? 's' : ''} trouvé${filteredTasks.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: HexColor('#1A365D'),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              if (_searchQuery.isNotEmpty)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                  child: Text(
                                    'Effacer',
                                    style: TextStyle(
                                      color: HexColor('#FF5C02'),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Liste des résultats
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredTasks.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 16),
                            itemBuilder: (context, i) {
                              final task = filteredTasks[i];
                              return _SearchTaskCard(
                                title: task.title,
                                time: _formatTaskDate(task),
                                status: _mapStatus(task.status),
                                statusColor: _statusColor(task.status),
                                priority: _mapPriority(task.priority),
                                priorityColor: _priorityColor(task.priority),
                                description: task.description,
                                searchQuery: _searchQuery,
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchTaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String description;
  final String searchQuery;

  const _SearchTaskCard({
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.description,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Terminée';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    children: _buildHighlightedText(title, searchQuery),
                  ),
                ),
              ),
              Text(
                priority,
                style: TextStyle(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF8A98A8)),
              const SizedBox(width: 6),
              Text(
                time,
                style: const TextStyle(color: Color(0xFF8A98A8), fontSize: 15),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Color(0xFF8A98A8), fontSize: 14),
                children: _buildHighlightedText(description, searchQuery),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Terminée',
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color:
                          status == 'Terminée'
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF8A98A8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return [TextSpan(text: text)];
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final List<TextSpan> spans = [];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Color(0xFFFF5C02),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      start = index + query.length;
    }

    return spans;
  }
}
