import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my2doapp/googleAuth_helper.dart';
import 'models/task.dart';
import 'models/todo.dart';

// ignore: camel_case_types
class DatabaseHelper_fs {
  final _firestoreInstance = Firestore.instance;

  Future<String> insertTask(Task task) async {
    String docId = "";
    var docRef = (await _firestoreInstance.collection("Task").add(task.toMap()));
    docId = docRef.documentID;
    print("created doc id:$docId");
    return docId;
  }

  Future<void> insertTodo(String taskId, Todo todo) async {
    _firestoreInstance.collection("Task").document(taskId).collection("Todos").add(todo.toMap());
  }

  Future<void> updateTaskTitle(String id, String title) async {
    _firestoreInstance.collection("Task").document(id).updateData({"title": title});
  }

  Future<void> updateTaskDescription(String id, String description) async {
    _firestoreInstance.collection("Task").document(id).updateData({"description": description});
  }

  Future<void> updateTaskDueDate(String id, String dueDate) async {
    _firestoreInstance.collection("Task").document(id).updateData({"dueDate": dueDate});
  }

  Future<void> updateTaskPriority(String id, int priority) async {
    _firestoreInstance.collection("Task").document(id).updateData({"priority": priority});
  }

  Future<void> deleteTask(String id) async {
    _firestoreInstance.collection("Task").document(id).delete();
  }

  Future<void> deleteTodoTask(String taskId, String todoId) async {
    _firestoreInstance.collection("Task").document(taskId).collection("Todos").document(todoId).delete();
  }

  Future<void> updateTodoDone(String taskId, String todoId, int isDone) async {
    _firestoreInstance.collection("Task").document(taskId).collection("Todos").document(todoId).updateData({"isDone": isDone});
  }

  Future<void> updateTaskDone(String id, int isDone) async {
    _firestoreInstance.collection("Task").document(id).updateData({"isDone": isDone});
  }

  Future<Task> getTask(String id) async {
    return _firestoreInstance.collection("Task").document(id).get().then((querySnapshot) => Task(
          description: querySnapshot.data["description"],
          id: querySnapshot.data["id"],
          title: querySnapshot.data["title"],
          priority: querySnapshot.data["priority"],
          isDone: querySnapshot.data["isDone"],
          dueDate: querySnapshot.data["dueDate"],
        ));
  }

  Future<List<Task>> getTasks() async {
    return _firestoreInstance
        .collection("Task")
        .where("email", isEqualTo: GoogleAuthHelper.userEmail)
        .getDocuments()
        .then((querySnapshot) => List.generate(querySnapshot.documents.length, (index) {
              return Task(
                id: querySnapshot.documents[index].documentID,
                title: querySnapshot.documents[index]["title"],
                description: querySnapshot.documents[index]["description"],
                dueDate: querySnapshot.documents[index]["dueDate"],
                priority: querySnapshot.documents[index]["priority"],
                isDone: querySnapshot.documents[index]["isDone"],
              );
            }));
  }

  Future<List<Task>> getDoneTasks() async {
    return _firestoreInstance
        .collection("Task")
        .where("email", isEqualTo: GoogleAuthHelper.userEmail)
        .where("isDone", isEqualTo: 1)
        .getDocuments()
        .then((querySnapshot) => List.generate(querySnapshot.documents.length, (index) {
              return Task(
                id: querySnapshot.documents[index].documentID,
                title: querySnapshot.documents[index]["title"],
                description: querySnapshot.documents[index]["description"],
                dueDate: querySnapshot.documents[index]["dueDate"],
                priority: querySnapshot.documents[index]["priority"],
                isDone: querySnapshot.documents[index]["isDone"],
              );
            }));
  }

  Future<List<Task>> getOpenTasks() async {
    return _firestoreInstance
        .collection("Task")
        .where("email", isEqualTo: GoogleAuthHelper.userEmail)
        .where("isDone", isEqualTo: 0)
        .getDocuments()
        .then((querySnapshot) => List.generate(querySnapshot.documents.length, (index) {
              return Task(
                id: querySnapshot.documents[index].documentID,
                title: querySnapshot.documents[index]["title"],
                description: querySnapshot.documents[index]["description"],
                dueDate: querySnapshot.documents[index]["dueDate"],
                priority: querySnapshot.documents[index]["priority"],
                isDone: querySnapshot.documents[index]["isDone"],
              );
            }));
  }

  Future<List<Todo>> getTodos(String taskId) async {
    return _firestoreInstance.collection("Task").document(taskId).collection("Todos").getDocuments().then((querySnapshot) => List.generate(querySnapshot.documents.length, (index) {
          return Todo(
            id: querySnapshot.documents[index].documentID,
            taskId: querySnapshot.documents[index]["taskId"],
            title: querySnapshot.documents[index]["title"],
            dueDate: querySnapshot.documents[index]["dueDate"],
            priority: querySnapshot.documents[index]["priority"],
            isDone: querySnapshot.documents[index]["isDone"],
          );
        }));
  }

  Future<List<Task>> getSearchResult(String q) async {
    List<Task> tasks = [];
    (await _firestoreInstance.collection("Task").where("email", isEqualTo: GoogleAuthHelper.userEmail).getDocuments()).documents.forEach((element) {
      var task = Task(
        isDone: element.data["isDone"],
        priority: element.data["priority"],
        description: element.data["description"],
        email: element.data["email"],
        dueDate: element.data["dueDate"],
        title: element.data["title"],
        id: element.data["id"],
      );
      tasks.add(task);
    });
    return tasks.where((element) => element.title.contains(q)).toList();
  }
}
