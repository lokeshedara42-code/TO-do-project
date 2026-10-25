
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoTask {
  String title;
  bool completed;

  TodoTask(this.title, {this.completed = false});

  Map<String, dynamic> toJson() => {
        'title': title,
        'completed': completed,
      };

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      json['title'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final controller = TextEditingController();
  final List<TodoTask> tasks = [];
  String filter = 'All';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('tasks');

    if (saved == null) return;

    try {
      final List<dynamic> decoded = jsonDecode(saved);

      if (!mounted) return;
      setState(() {
        tasks
          ..clear()
          ..addAll(
            decoded.map(
              (item) => TodoTask.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            ),
          );
      });
    } catch (_) {
      // Keep the app usable if saved data is invalid.
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'tasks',
      jsonEncode(tasks.map((task) => task.toJson()).toList()),
    );
  }

  void addTask() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      tasks.add(TodoTask(text));
      controller.clear();
    });

    saveTasks();
  }

  void toggleTask(TodoTask task, bool? value) {
    setState(() => task.completed = value ?? false);
    saveTasks();
  }

  void deleteTask(TodoTask task) {
    setState(() => tasks.remove(task));
    saveTasks();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = tasks.where((task) {
      if (filter == 'Pending') return !task.completed;
      if (filter == 'Completed') return task.completed;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My To-Do List')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Enter a task',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => addTask(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addTask,
                child: const Text('Add Task'),
              ),
            ),
            const SizedBox(height: 10),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'Pending', label: Text('Pending')),
                ButtonSegment(
                  value: 'Completed',
                  label: Text('Completed'),
                ),
              ],
              selected: {filter},
              onSelectionChanged: (value) {
                setState(() => filter = value.first);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: visibleTasks.length,
                itemBuilder: (context, index) {
                  final task = visibleTasks[index];

                  return CheckboxListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    value: task.completed,
                    onChanged: (value) => toggleTask(task, value),
                    secondary: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => deleteTask(task),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
