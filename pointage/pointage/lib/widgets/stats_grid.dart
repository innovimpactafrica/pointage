import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/worker/worker_dashboard_bloc.dart';
import '../bloc/worker/worker_dashboard_event.dart';
import '../bloc/worker/worker_dashboard_state.dart';
import '../repository/worker_dashboard_repository.dart';
import '../services/worker_service.dart';

class StatsGrid extends StatelessWidget {
  final int workerId;

  const StatsGrid({Key? key, required this.workerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WorkerDashboardBloc>(
      create:
          (_) => WorkerDashboardBloc(
            repository: WorkerDashboardRepository(
              workerService: WorkerService(),
            ),
          )..add(LoadWorkerDashboardEvent(workerId)),
      child: BlocBuilder<WorkerDashboardBloc, WorkerDashboardState>(
        builder: (context, state) {
          if (state is WorkerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WorkerDashboardLoaded) {
            final dashboard = state.dashboard;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: dashboard.daysPresent.toString(),
                          label: 'Jours présents',
                          color: const Color(0xFFFF5C02),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          value: '${dashboard.totalWorkedHours}h',
                          label: 'Heures travaillées',
                          color: const Color(0xFFFF5C02),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: dashboard.completedTasks.toString(),
                          label: 'Tâches terminées',
                          color: const Color(0xFFFF5C02),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          value: '${dashboard.performancePercentage}%',
                          label: 'Performance',
                          color: const Color(0xFFFF5C02),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is WorkerDashboardError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2C3E50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
