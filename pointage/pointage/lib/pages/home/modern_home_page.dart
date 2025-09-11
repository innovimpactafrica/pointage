import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/AuthService.dart';
import '../../models/UserModel.dart';
import '../../models/TaskModel.dart';
import '../../widgets/stats_grid.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../repository/task_repository.dart';
import '../../services/task_service.dart';
import '../tasks/modern_tasks_page.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({Key? key}) : super(key: key);

  @override
  State<ModernHomePage> createState() => _ModernHomePageState();
}

class _ModernHomePageState extends State<ModernHomePage> {
  final _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(currentUser: _currentUser),
            Transform.translate(
              offset: const Offset(0, -30),
              child: _WelcomeCard(currentUser: _currentUser),
            ),
            if (_currentUser != null) StatsGrid(workerId: _currentUser!.id),
            const SizedBox(height: 32),
            _TodayTasksSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final UserModel? currentUser;

  const _HeaderSection({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: const BoxDecoration(color: Color(0xFF1A365D)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF5C02).withOpacity(0.1),
            ),
            child: const Icon(Icons.person, size: 30, color: Color(0xFFFF5C02)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currentUser != null
                      ? '${currentUser!.prenom} ${currentUser!.nom}'
                      : 'Utilisateur',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.profil ?? 'Employé',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 12,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5C02),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final UserModel? currentUser;

  const _WelcomeCard({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentUser != null
                ? 'Bonjour, ${currentUser!.prenom} ${currentUser!.nom}'
                : 'Bonjour, Utilisateur',
            style: const TextStyle(
              color: Color(0xFF183B63),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Voici votre activité pour aujourd'hui",
            style: TextStyle(
              color: Color(0xFF8A98A8),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTasksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create:
          (_) => TaskBloc(
            taskRepository: TaskRepository(taskService: TaskService()),
          ),
      child: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          // Charger les tâches si pas encore chargées
          if (state is TaskInitial) {
            // Récupérer l'ID de l'utilisateur depuis le contexte parent
            final user =
                context
                    .findAncestorStateOfType<_ModernHomePageState>()
                    ?._currentUser;
            if (user != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                BlocProvider.of<TaskBloc>(context).add(LoadTasksEvent(user.id));
              });
            }
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tâches aujourd'hui",
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigation vers la page des tâches
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ModernTasksPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Voir plus',
                        style: TextStyle(
                          color: Color(0xFFFF5C02),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (state is TaskLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is TaskError)
                  Center(
                    child: Text(
                      'Erreur: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                else if (state is TaskLoaded)
                  ..._buildTaskCards(context, state.tasks)
                else
                  const Center(
                    child: Text(
                      'Aucune tâche trouvée',
                      style: TextStyle(color: Color(0xFF8A98A8)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTaskCards(BuildContext context, List<TaskModel> tasks) {
    // Filtrer les tâches non terminées et prendre les 2 premières
    final activeTasks =
        tasks.where((task) => task.status != 'DONE').take(2).toList();

    if (activeTasks.isEmpty) {
      return [
        const Center(
          child: Text(
            'Aucune tâche active',
            style: TextStyle(color: Color(0xFF8A98A8)),
          ),
        ),
      ];
    }

    return activeTasks.map((task) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _TaskCard(
          task: task,
          onAction: () {
            _handleTaskAction(context, task);
          },
        ),
      );
    }).toList();
  }

  void _handleTaskAction(BuildContext context, TaskModel task) {
    String newStatus;
    String actionText;

    switch (task.status) {
      case 'TODO':
        newStatus = 'IN_PROGRESS';
        actionText = 'Commencer';
        break;
      case 'IN_PROGRESS':
        newStatus = 'DONE';
        actionText = 'Terminer';
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(actionText),
            content: Text('Voulez-vous $actionText la tâche "${task.title}" ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  BlocProvider.of<TaskBloc>(
                    context,
                  ).add(UpdateTaskStatusEvent(task.id, newStatus));
                },
                child: Text(actionText),
              ),
            ],
          ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onAction;

  const _TaskCard({required this.task, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    color: Color(0xFF34495E),
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                _getPriorityText(task.priority),
                style: TextStyle(
                  color: _getPriorityColor(task.priority),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: Color(0xFF6C757D)),
              const SizedBox(width: 6),
              Text(
                _formatTaskDate(task),
                style: const TextStyle(color: Color(0xFF6C757D), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F2F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(task.status),
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              if (_canPerformAction(task.status))
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    elevation: 0,
                  ),
                  onPressed: onAction,
                  icon: Icon(
                    _getActionIcon(task.status),
                    size: 20,
                    color: Colors.white,
                  ),
                  label: Text(
                    _getActionLabel(task.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPriorityText(String priority) {
    switch (priority.toUpperCase()) {
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

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFFF3B30);
      case 'MEDIUM':
        return const Color(0xFFFFA726);
      case 'LOW':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF8A98A8);
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
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

  String _getActionLabel(String status) {
    switch (status.toUpperCase()) {
      case 'TODO':
        return 'Commencer';
      case 'IN_PROGRESS':
        return 'Terminer';
      case 'DONE':
        return 'Terminée';
      default:
        return '';
    }
  }

  IconData _getActionIcon(String status) {
    switch (status.toUpperCase()) {
      case 'TODO':
        return Icons.play_arrow;
      case 'IN_PROGRESS':
        return Icons.check;
      case 'DONE':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  bool _canPerformAction(String status) {
    return status.toUpperCase() == 'TODO' ||
        status.toUpperCase() == 'IN_PROGRESS';
  }

  String _formatTaskDate(TaskModel task) {
    if (task.startDate != null && task.endDate != null) {
      final start = task.startDate!;
      final end = task.endDate!;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDay = DateTime(start.year, start.month, start.day);

      if (startDay == today) {
        return 'Aujourd\'hui • ${_formatTime(start)} - ${_formatTime(end)}';
      } else if (startDay == today.add(const Duration(days: 1))) {
        return 'Demain • ${_formatTime(start)} - ${_formatTime(end)}';
      } else {
        return '${_formatDate(start)} • ${_formatTime(start)} - ${_formatTime(end)}';
      }
    }
    return 'Date non définie';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }
}
