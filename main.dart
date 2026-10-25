
class _TodoHomePageState extends State<TodoHomePage> {
  final controller = TextEditingController();
  final List<TodoTask> tasks = [];
  String filter = 'All';

  void addTask() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      tasks.add(TodoTask(text));
      controller.clear();
    });
  }

  void deleteTask(TodoTask task) {
    setState(() => tasks.remove(task));
  }

  void toggleTask(TodoTask task, bool? value) {
    setState(() => task.completed = value ?? false);
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
