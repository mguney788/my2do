class Todo {
  final String id;
  final String taskId;
  final String title;
  final String dueDate;
  final int priority;
  final int isDone;

  Todo({this.id, this.taskId, this.title, this.isDone, this.dueDate, this.priority});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isDone': isDone,
      'dueDate': dueDate,
      'priority': priority,
    };
  }
}
