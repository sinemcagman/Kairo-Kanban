import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/enums.dart';
import '../../domain/models/task_model.dart';

final kanbanProvider =
    NotifierProvider<KanbanNotifier, List<TaskModel>>(() {
  return KanbanNotifier();
});

class KanbanNotifier extends Notifier<List<TaskModel>> {
  @override
  List<TaskModel> build() {
    return [
      TaskModel(
        id: const Uuid().v4(),
        title: 'Kullanıcı giriş ekranı tasarımı',
        description: 'Login ve register sayfalarının UI tasarımını oluştur.',
        status: TaskStatus.todo,
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Veritabanı şemasını belirle',
        description: 'Kullanıcı, görev ve proje tabloları için şema çiz.',
        status: TaskStatus.todo,
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'API entegrasyonu',
        description: 'Backend REST API bağlantılarını kur ve test et.',
        status: TaskStatus.inProgress,
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Bildirim sistemi geliştirme',
        description: 'Push notification altyapısını Firebase ile entegre et.',
        status: TaskStatus.inProgress,
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Proje kurulumu',
        description: 'Flutter projesi oluşturuldu ve bağımlılıklar eklendi.',
        status: TaskStatus.done,
      ),
      TaskModel(
        id: const Uuid().v4(),
        title: 'Renk paleti ve tema',
        description: 'Dark theme renk paleti ve AppTheme yapılandırması.',
        status: TaskStatus.done,
      ),
    ];
  }

  void addTask(String title, String description, TaskStatus status) {
    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: status,
    );
    state = [...state, newTask];
  }

  void updateTask(String id, String newTitle, String newDescription) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(title: newTitle, description: newDescription)
        else
          task
    ];
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }

  void moveTask(String id, TaskStatus newStatus) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(status: newStatus) else task
    ];
  }
}
