class Task {
  final String email;
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final int priority;
  final int isDone;

  Task({this.email,this.id, this.title, this.description, this.dueDate, this.priority, this.isDone});

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'id':id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isDone': isDone,
    };
  }
}
