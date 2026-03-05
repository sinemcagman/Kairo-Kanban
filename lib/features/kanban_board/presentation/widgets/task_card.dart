import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/models/task_model.dart';
import '../providers/kanban_provider.dart';
import 'task_dialog.dart';

class TaskCard extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskCard({super.key, required this.task});

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _isHovered = false;

  Color get _statusColor {
    switch (widget.task.status) {
      case TaskStatus.todo:
        return AppColors.todo;
      case TaskStatus.inProgress:
        return AppColors.inProgress;
      case TaskStatus.done:
        return AppColors.done;
    }
  }

  LinearGradient get _statusGradient {
    switch (widget.task.status) {
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
    final notifier = ref.read(kanbanProvider.notifier);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: LongPressDraggable<TaskModel>(
        data: widget.task,
        delay: const Duration(milliseconds: 150),
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 280,
            child: _buildCard(isDragging: true),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.25,
          child: _buildCard(),
        ),
        child: GestureDetector(
          onTap: () => _showEditDialog(context, notifier),
          child: _buildCard(),
        ),
      ),
    );
  }

  Widget _buildCard({bool isDragging = false}) {
    final isActive = _isHovered || isDragging;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.surfaceLight
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? _statusColor.withOpacity(0.4)
              : AppColors.border.withOpacity(0.3),
        ),
        boxShadow: isActive ? AppColors.glowShadow(_statusColor) : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              gradient: _statusGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                    _buildMenu(),
                  ],
                ),
                if (widget.task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.task.description,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.8),
                      fontSize: 12,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildIdChip(),
                    const Spacer(),
                    Icon(
                      Icons.drag_indicator_rounded,
                      size: 14,
                      color: AppColors.textSecondary.withOpacity(0.3),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#${widget.task.id.substring(0, 6)}',
        style: TextStyle(
          fontSize: 10,
          color: _statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenu() {
    final notifier = ref.read(kanbanProvider.notifier);
    return SizedBox(
      width: 24,
      height: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_rounded,
                    size: 14, color: AppColors.primaryLight),
                const SizedBox(width: 8),
                const Text('Düzenle',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textPrimary)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_rounded,
                    size: 14, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Text('Sil',
                    style:
                        TextStyle(fontSize: 13, color: Colors.red.shade400)),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'edit') {
            _showEditDialog(context, notifier);
          } else if (value == 'delete') {
            notifier.deleteTask(widget.task.id);
          }
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, KanbanNotifier notifier) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => TaskDialog(
        taskToEdit: widget.task,
        kanbanNotifier: notifier,
      ),
    );
  }
}