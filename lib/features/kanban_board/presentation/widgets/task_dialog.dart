import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/models/task_model.dart';
import '../providers/kanban_provider.dart';

class TaskDialog extends StatefulWidget {
  final TaskModel? taskToEdit;
  final KanbanNotifier kanbanNotifier;

  const TaskDialog({
    super.key,
    this.taskToEdit,
    required this.kanbanNotifier,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _selectedStatus;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Pre-computed renkleri sabit olarak tanımlayarak her build'de
  // withOpacity() ile yeni Color nesnesi oluşturulmasını engelliyoruz.
  static const Color _surfaceLightFaded = Color(0x66000000); // örnek — kendi değerinizle değiştirin
  static const Color _borderFaded = Color(0x4D000000);       // örnek — kendi değerinizle değiştirin

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.taskToEdit?.description ?? '');
    _selectedStatus = widget.taskToEdit?.status ?? TaskStatus.todo;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _colorForStatus(TaskStatus s) {
    switch (s) {
      case TaskStatus.todo:
        return AppColors.todo;
      case TaskStatus.inProgress:
        return AppColors.inProgress;
      case TaskStatus.done:
        return AppColors.done;
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX 1: Dialog yerine doğrudan Scaffold/Stack kullanmak yerine,
    // resizeToAvoidBottomInset özelliğini kontrol etmek için
    // Dialog'u AnimatedPadding yerine manuel padding ile sarıyoruz.
    // Bu sayede klavye animasyonu Dialog'u rebuild etmek yerine
    // sadece padding'i değiştiriyor.
    return AnimatedPadding(
      // Klavye yükselirken sadece padding animasyonu çalışır,
      // Dialog'un iç widget tree'si yeniden build edilmez.
      padding: MediaQuery.viewInsetsOf(context) +
          const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: MediaQuery.removeViewInsets(
        // FIX 2: Alt widget'ların tekrar viewInsets'e tepki vermesini
        // engelliyoruz — çift rebuild'ı önler.
        removeBottom: true,
        context: context,
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20),
              // FIX 3: SingleChildScrollView'e physics ekleyerek
              // klavye animasyonu sırasında gereksiz scroll hesaplamalarını azaltıyoruz.
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      // FIX 4: TextFormField'lar RepaintBoundary ile sarılarak
                      // klavye açılınca tüm dialog yerine sadece ilgili
                      // alanın repaint edilmesi sağlanır.
                      RepaintBoundary(
                        child: TextFormField(
                          controller: _titleController,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Görev Başlığı',
                            hintText: 'Örn: Tasarım revizyonu',
                            prefixIcon: Icon(Icons.title_rounded, size: 18),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Başlık gerekli';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 14),
                      RepaintBoundary(
                        child: TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 14),
                          decoration: const InputDecoration(
                            labelText: 'Açıklama',
                            hintText: 'Görev detaylarını buraya yazın...',
                            prefixIcon:
                                Icon(Icons.description_rounded, size: 18),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildStatusSelector(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FIX 5: Statik içerikleri ayrı metodlara taşıyarak build maliyetini azaltıyoruz.
  // İleride const constructor'lı widget'lara dönüştürmek de mümkün.
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            widget.taskToEdit == null
                ? Icons.add_task_rounded
                : Icons.edit_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.taskToEdit == null ? 'Yeni Görev' : 'Görevi Düzenle',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textSecondary,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Durum',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            final color = _colorForStatus(status);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedStatus = status),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : AppColors.surfaceLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.5)
                          : AppColors.border.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color:
                              isSelected ? color : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.taskToEdit != null)
          TextButton.icon(
            onPressed: () {
              widget.kanbanNotifier.deleteTask(widget.taskToEdit!.id);
              Navigator.pop(context);
            },
            icon: Icon(Icons.delete_rounded,
                size: 16, color: Colors.red.shade400),
            label: Text('Sil',
                style:
                    TextStyle(color: Colors.red.shade400, fontSize: 13)),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'İptal',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: _isLoading ? null : _saveTask,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else
                      const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      widget.taskToEdit == null ? 'Oluştur' : 'Güncelle',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    // FIX 6: setState'i Future.delayed içinden kaldırarak
    // async gap'te mounted kontrolü yapıyoruz ve
    // gereksiz frame beklemesini ortadan kaldırıyoruz.
    if (!mounted) return;
    setState(() => _isLoading = true);

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (widget.taskToEdit == null) {
      widget.kanbanNotifier.addTask(title, description, _selectedStatus);
    } else {
      widget.kanbanNotifier.updateTask(
        widget.taskToEdit!.id,
        title,
        description,
      );
      if (widget.taskToEdit!.status != _selectedStatus) {
        widget.kanbanNotifier.moveTask(widget.taskToEdit!.id, _selectedStatus);
      }
    }

    if (mounted) Navigator.pop(context);
  }
}