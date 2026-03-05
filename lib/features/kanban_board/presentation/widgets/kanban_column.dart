import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/models/task_model.dart';
import '../providers/kanban_provider.dart';
import 'task_card.dart';

class KanbanColumn extends ConsumerStatefulWidget {
  final TaskStatus status;
  final String title;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.title,
  });

  @override
  ConsumerState<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends ConsumerState<KanbanColumn> {
  bool _isDragOver = false;

  Color get statusColor {
    switch (widget.status) {
      case TaskStatus.todo:
        return AppColors.todo;
      case TaskStatus.inProgress:
        return AppColors.inProgress;
      case TaskStatus.done:
        return AppColors.done;
    }
  }

  LinearGradient get statusGradient {
    switch (widget.status) {
      case TaskStatus.todo:
        return AppColors.todoGradient;
      case TaskStatus.inProgress:
        return AppColors.inProgressGradient;
      case TaskStatus.done:
        return AppColors.doneGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref
        .watch(kanbanProvider)
        .where((t) => t.status == widget.status)
        .toList();
    final notifier = ref.read(kanbanProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        children: [
          _buildHeader(tasks.length),
          const SizedBox(height: 10),
          Expanded(
            child: DragTarget<TaskModel>(
              onWillAcceptWithDetails: (details) {
                if (details.data.status != widget.status) {
                  setState(() => _isDragOver = true);
                  return true;
                }
                return false;
              },
              onLeave: (_) {
                setState(() => _isDragOver = false);
              },
              onAcceptWithDetails: (details) {
                setState(() => _isDragOver = false);
                notifier.moveTask(details.data.id, widget.status);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: statusColor, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.title} sütununa taşındı',
                          style:
                              const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.surfaceLight,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              builder: (context, candidateData, rejectedData) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: _isDragOver
                        ? statusColor.withOpacity(0.06)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isDragOver
                          ? statusColor.withOpacity(0.4)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: tasks.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(6),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return TaskCard(
                              key: ValueKey(tasks[index].id),
                              task: tasks[index],
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: statusGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 36,
            color: AppColors.textSecondary.withOpacity(0.25),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz görev yok',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}