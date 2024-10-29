import 'dart:convert';

class Task {
  String name;
  String description;
  DateTime deadline;
  String priority;
  String status;
  bool isDone;

  Task({
    required this.name,
    required this.description,
    required this.deadline,
    required this.priority,
    required this.status,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'deadline': deadline.toIso8601String(),
        'priority': priority,
        'status': status,
        'isDone': isDone,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        description: json['description'],
        deadline: DateTime.parse(json['deadline']),
        priority: json['priority'],
        status: json['status'],
        isDone: json['isDone'],
      );
}
