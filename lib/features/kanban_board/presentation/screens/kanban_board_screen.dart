import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../providers/kanban_provider.dart';
import '../widgets/kanban_column.dart';
import '../widgets/task_dialog.dart';

class KanbanBoardScreen extends ConsumerStatefulWidget {
  const KanbanBoardScreen({super.key});

  @override
  ConsumerState<KanbanBoardScreen> createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends ConsumerState<KanbanBoardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(kanbanProvider.notifier);
    final allTasks = ref.watch(kanbanProvider);
    final todoCount = allTasks.where((t) => t.status == TaskStatus.todo).length;
    final progressCount =
        allTasks.where((t) => t.status == TaskStatus.inProgress).length;
    final doneCount = allTasks.where((t) => t.status == TaskStatus.done).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        titleSpacing: 16,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'Kairo Board',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          dividerColor: AppColors.border.withOpacity(0.3),
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          tabs: [
            _buildTab('To-Do', todoCount, AppColors.todo),
            _buildTab('Devam', progressCount, AppColors.inProgress),
            _buildTab('Bitti', doneCount, AppColors.done),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              children: [
                Expanded(
                  child: KanbanColumn(
                    status: TaskStatus.todo,
                    title: TaskStatus.todo.displayName,
                  ),
                ),
                Expanded(
                  child: KanbanColumn(
                    status: TaskStatus.inProgress,
                    title: TaskStatus.inProgress.displayName,
                  ),
                ),
                Expanded(
                  child: KanbanColumn(
                    status: TaskStatus.done,
                    title: TaskStatus.done.displayName,
                  ),
                ),
              ],
            );
          } else {
            return TabBarView(
              controller: _tabController,
              children: [
                KanbanColumn(
                  status: TaskStatus.todo,
                  title: TaskStatus.todo.displayName,
                ),
                KanbanColumn(
                  status: TaskStatus.inProgress,
                  title: TaskStatus.inProgress.displayName,
                ),
                KanbanColumn(
                  status: TaskStatus.done,
                  title: TaskStatus.done.displayName,
                ),
              ],
            );
          }
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.glowShadow(AppColors.primary),
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _showAddTaskDialog(context, notifier),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            'Görev Ekle',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count, Color color) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, KanbanNotifier notifier) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => TaskDialog(kanbanNotifier: notifier),
    );
  }
}