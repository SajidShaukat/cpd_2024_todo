import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'task.dart';

// Interface für Storage-Typen
abstract class TaskStorage {
  Future<void> saveTasks(List<Task> tasks);
  Future<List<Task>> loadTasks();
  Future<void> clearTasks();
}

// Speicherung in SharedPreferences
class SharedPreferencesStorage implements TaskStorage {
  static const String _taskKey = 'tasks';

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String taskJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString(_taskKey, taskJson);
  }

  @override
  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? taskJson = prefs.getString(_taskKey);
    if (taskJson == null) return [];
    final List<dynamic> taskList = jsonDecode(taskJson);
    return taskList.map((task) => Task.fromJson(task)).toList();
  }

  @override
  Future<void> clearTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_taskKey);
  }
}

// Speicherung in Hive mit JSON-Konvertierung
class HiveStorage implements TaskStorage {
  static const String _boxName = 'taskBox';

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final box = await Hive.openBox<String>(_boxName);
    final String taskJson = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await box.put(_boxName, taskJson); // Speichert die gesamte Liste als JSON-String
  }

  @override
  Future<List<Task>> loadTasks() async {
    final box = await Hive.openBox<String>(_boxName);
    final String? taskJson = box.get(_boxName);
    if (taskJson == null) return [];
    final List<dynamic> taskList = jsonDecode(taskJson);
    return taskList.map((task) => Task.fromJson(task)).toList();
  }

  @override
  Future<void> clearTasks() async {
    final box = await Hive.openBox<String>(_boxName);
    await box.clear();
  }
}
