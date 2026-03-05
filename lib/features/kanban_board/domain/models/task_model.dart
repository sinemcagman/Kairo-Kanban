import '../../../../core/utils/enums.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
    );
  }

  // To/From JSON for future local storage (Hive/SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
    );
  }
}
