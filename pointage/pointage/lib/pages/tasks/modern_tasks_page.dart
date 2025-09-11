import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/HexColor.dart';
import '../../utils/DottedBorderPainter.dart';
import '../../services/AuthService.dart';
import '../../models/UserModel.dart';
import '../../models/TaskModel.dart';
import '../../repository/task_repository.dart';
import '../../services/task_service.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'search_tasks_page.dart';

class ModernTasksPage extends StatefulWidget {
  const ModernTasksPage({Key? key}) : super(key: key);

  @override
  State<ModernTasksPage> createState() => _ModernTasksPageState();
}

class _ModernTasksPageState extends State<ModernTasksPage> {
  int _selectedFilter = 0;
  final List<String> _filters = [
    'Toutes',
    'En attente',
    'En cours',
    'Terminées',
  ];
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

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Erreur: Utilisateur non trouvé')),
      );
    }

    return BlocProvider<TaskBloc>(
      create:
          (_) => TaskBloc(
            taskRepository: TaskRepository(taskService: TaskService()),
          )..add(LoadTasksEvent(_currentUser!.id)),
      child: Container(
        color: HexColor('#F1F2F6'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TachesHeader(),
            const SizedBox(height: 10),
            _TachesFilters(
              filters: _filters,
              selected: _selectedFilter,
              onChanged: (i) => setState(() => _selectedFilter = i),
            ),
            const SizedBox(height: 18),
            Expanded(child: _TasksList()),
          ],
        ),
      ),
    );
  }

  List<TaskModel> _filterTasks(List<TaskModel> tasks, int selectedFilter) {
    switch (selectedFilter) {
      case 1:
        return tasks.where((t) => t.status == 'TODO').toList();
      case 2:
        return tasks.where((t) => t.status == 'IN_PROGRESS').toList();
      case 3:
        return tasks.where((t) => t.status == 'DONE').toList();
      default:
        return tasks;
    }
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

  String _actionLabel(String status) {
    switch (status) {
      case 'TODO':
        return 'Commencer';
      case 'IN_PROGRESS':
        return 'Terminer';
      case 'DONE':
        return '';
      default:
        return '';
    }
  }

  IconData? _actionIcon(String status) {
    switch (status) {
      case 'TODO':
        return Icons.play_arrow;
      case 'IN_PROGRESS':
        return Icons.check;
      default:
        return null;
    }
  }

  Widget _TasksList() {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskError) {
          return Center(
            child: Text(state.message, style: TextStyle(color: Colors.red)),
          );
        } else if (state is TaskLoaded) {
          final tasks = _filterTasks(state.tasks, _selectedFilter);
          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment,
                    size: 64,
                    color: Color(0xFF8A98A8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune tâche trouvée.',
                    style: TextStyle(color: Color(0xFF8A98A8), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tasks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final task = tasks[i];
              return _TacheCard(
                title: task.title,
                time: _formatTaskDate(task),
                status: _mapStatus(task.status),
                statusColor: _statusColor(task.status),
                priority: _mapPriority(task.priority),
                priorityColor: _priorityColor(task.priority),
                actionLabel: _actionLabel(task.status),
                actionColor: const Color(0xFFFF5C02),
                actionIcon: _actionIcon(task.status),
                taskModel: task,
                onStatusChanged: () {
                  // Rafraîchir le bloc
                  if (_currentUser != null) {
                    BlocProvider.of<TaskBloc>(
                      context,
                    ).add(LoadTasksEvent(_currentUser!.id));
                  }
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TachesHeader extends StatelessWidget {
  const _TachesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(color: HexColor('#1A365D')),
      padding: EdgeInsets.only(left: 20, right: 20, top: 50, bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Mes Tâches',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchTasksPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _TachesFilters extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onChanged;
  const _TachesFilters({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (i) {
          final isActive = i == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color:
                      isActive ? HexColor('#FF5C02') : const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: isActive ? Colors.white : HexColor('#1A365D'),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TacheCard extends StatelessWidget {
  final String title;
  final String time;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String actionLabel;
  final Color actionColor;
  final IconData? actionIcon;
  final TaskModel? taskModel;
  final VoidCallback? onStatusChanged;
  const _TacheCard({
    required this.title,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.actionLabel,
    required this.actionColor,
    required this.actionIcon,
    this.taskModel,
    this.onStatusChanged,
  });

  Future<void> _handleAction(BuildContext context) async {
    if (taskModel == null) return;
    final isTodo = taskModel!.status == 'TODO';
    final action = isTodo ? 'commencer' : 'terminer';
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskActionConfirmBottomSheet(action: action),
    );
    if (confirmed == true) {
      // Appel API pour changer le statut
      final nextStatus = isTodo ? 'IN_PROGRESS' : 'DONE';
      await TaskService().updateTaskStatus(taskModel!.id, nextStatus);
      if (onStatusChanged != null) onStatusChanged!();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Statut mis à jour !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'Terminée';
    final isInProgress = status == 'En cours';
    final isTodo = status == 'En attente';
    return GestureDetector(
      onTap:
          taskModel != null
              ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  builder:
                      (_) => TaskDetailBottomSheet(
                        task: taskModel!,
                        onStatusChanged: onStatusChanged,
                      ),
                );
              }
              : null,
      child: Container(
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A365D),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF8A98A8),
                ),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF8A98A8),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
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
                const Spacer(),
                if (isTodo)
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
                    onPressed: () => _handleAction(context),
                    icon: const Icon(
                      Icons.play_arrow,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Commencer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  )
                else if (isInProgress)
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
                    onPressed: () => _handleAction(context),
                    icon: const Icon(
                      Icons.check,
                      size: 20,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Terminé',
                      style: TextStyle(
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
      ),
    );
  }
}

class TaskDetailBottomSheet extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onStatusChanged;
  const TaskDetailBottomSheet({
    Key? key,
    required this.task,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  bool _loading = false;
  late TaskModel _task;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _loading = true;
    });
    try {
      final detail = await TaskService().fetchTaskDetail(widget.task.id);
      setState(() {
        _task = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _task = widget.task;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  _task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                if (_task.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    _task.description,
                    style: const TextStyle(
                      color: Color(0xFF8A98A8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class TaskActionConfirmBottomSheet extends StatelessWidget {
  final String action;
  const TaskActionConfirmBottomSheet({Key? key, required this.action})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTerminer = action == 'terminer';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            isTerminer ? 'Terminer la tâche ?' : 'Commencer la tâche ?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A365D),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 17, color: Color(0xFF8A98A8)),
              children: [
                const TextSpan(text: 'Souhaitez vous '),
                TextSpan(
                  text: action,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                const TextSpan(text: ' la tâche'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
              Container(width: 1, height: 28, color: const Color(0xFFE0E0E0)),
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(
                    isTerminer ? 'Oui, terminer' : 'Oui, commencer',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.bold,
                    ),
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

class TaskActionCompleteResult {
  final String comment;
  final List<File> photos;
  TaskActionCompleteResult({required this.comment, required this.photos});
}

class TaskActionCompleteBottomSheet extends StatefulWidget {
  final String taskTitle;
  final String action;
  const TaskActionCompleteBottomSheet({
    Key? key,
    required this.taskTitle,
    required this.action,
  }) : super(key: key);

  @override
  State<TaskActionCompleteBottomSheet> createState() =>
      _TaskActionCompleteBottomSheetState();
}

class _TaskActionCompleteBottomSheetState
    extends State<TaskActionCompleteBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<File> _photos = [];
  bool _loading = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _photos.add(File(picked.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final heure =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.action == 'terminer'
                      ? 'Tâche terminée'
                      : 'Tâche démarrée',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A365D),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8A98A8)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F9ED),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1A365D),
                  ),
                  children: [
                    TextSpan(
                      text: widget.taskTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ' terminée à '),
                    TextSpan(
                      text: heure,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ajouter un commentaire',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Saisir',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Ajouter des photos',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            CustomPaint(
              painter: DottedBorderPainter(
                radius: 12,
                color: const Color(0xFFFF5C02),
                dashPattern: const [6, 3],
                strokeWidth: 1.5,
              ),
              child: InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 90,
                  alignment: Alignment.center,
                  child:
                      _photos.isEmpty
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.camera_alt,
                                color: Color(0xFFFF5C02),
                                size: 32,
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Photo',
                                style: TextStyle(
                                  color: Color(0xFF8A98A8),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children:
                                _photos
                                    .map(
                                      (file) => Padding(
                                        padding: const EdgeInsets.all(6),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                file,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    _photos.remove(file);
                                                  });
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Color(0xFF8A98A8),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A365D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed:
                        _loading
                            ? null
                            : () {
                              Navigator.of(context).pop(
                                TaskActionCompleteResult(
                                  comment: _commentController.text,
                                  photos: _photos,
                                ),
                              );
                            },
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Ignorer',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF1A365D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
