import 'package:flutter/material.dart';
import 'task.dart';
import 'task_storage.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  String _selectedPriority = 'Niedrig';
  String _selectedStatus = 'Offen';
  late TaskStorage _storage;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storage = HiveStorage(); // Alternativ: SharedPreferencesStorage()
    await _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storage.loadTasks();
    setState(() {
      _tasks.addAll(tasks);
    });
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
  }

  DateTime _parseDate(String date) {
    try {
      final DateFormat format = DateFormat('dd.MM.yyyy');
      return format.parseStrict(date);
    } catch (e) {
      throw FormatException('Ungültiges Datum. Bitte gib das Datum im Format TT.MM.YYYY ein.');
    }
  }

  void _addTask() {
    try {
      DateTime deadline = _parseDate(_deadlineController.text);
      if (_nameController.text.isNotEmpty &&
          _descriptionController.text.isNotEmpty &&
          _deadlineController.text.isNotEmpty) {
        setState(() {
          _tasks.add(Task(
            name: _nameController.text,
            description: _descriptionController.text,
            deadline: deadline,
            priority: _selectedPriority,
            status: _selectedStatus,
          ));
          _clearInputs();
          _saveTasks();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    }
  }

  void _clearInputs() {
    _nameController.clear();
    _descriptionController.clear();
    _deadlineController.clear();
    _selectedPriority = 'Niedrig';
    _selectedStatus = 'Offen';
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aufgabenliste'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'Priorität') {
                  _tasks.sort((a, b) => a.priority.compareTo(b.priority));
                } else if (value == 'Dringlichkeit') {
                  _tasks.sort((a, b) => a.deadline.compareTo(b.deadline));
                } else if (value == 'Status') {
                  _tasks.sort((a, b) => a.status.compareTo(b.status));
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'Priorität', child: Text('Nach Priorität sortieren')),
              PopupMenuItem(value: 'Dringlichkeit', child: Text('Nach Dringlichkeit sortieren')),
              PopupMenuItem(value: 'Status', child: Text('Nach Status sortieren')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Aufgabenname'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Beschreibung'),
                ),
                TextField(
                  controller: _deadlineController,
                  decoration: InputDecoration(labelText: 'Deadline (TT.MM.YYYY)'),
                  keyboardType: TextInputType.datetime,
                ),
                DropdownButton<String>(
                  value: _selectedPriority,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPriority = newValue!;
                    });
                  },
                  items: <String>['Niedrig', 'Mittel', 'Hoch']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                  items: <String>['Offen', 'In Bearbeitung', 'Erledigt']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Aufgabe hinzufügen'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('${task.description}\nDeadline: ${_formatDate(task.deadline)}\nPriorität: ${task.priority}\nStatus: ${task.status}'),
                  isThreeLine: true,
                  trailing: Checkbox(
                    value: task.isDone,
                    onChanged: (bool? value) {
                      setState(() {
                        task.isDone = value!;
                        _saveTasks();
                      });
                    },
                  ),
                  onLongPress: () {
                    setState(() {
                      _tasks.removeAt(index);
                      _saveTasks();
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
