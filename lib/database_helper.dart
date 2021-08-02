import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/task.dart';
import 'models/todo.dart';

class DatabaseHelper {
  Future<Database> database() async {


    return openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT, dueDate TEXT, priority INTEGER, isDone INTEGER)");
        await db.execute("CREATE TABLE todo(id INTEGER PRIMARY KEY, taskId INTEGER, title TEXT,  dueDate TEXT, priority INTEGER, isDone INTEGER)");
        return db;
      },
      version: 1,
    );
  }

  Future<int> insertTask(Task task) async {
    Database _db = await database();
    int taskId = 0;
    await _db.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace).then((value) {
      taskId = value;
    });
    return taskId;
  }

  Future<void> insertTodo(Todo todo) async {
    Database _db = await database();
    await _db.insert('todo', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTaskTitle(int id, String title) async {
    Database _db = await database();
    await _db.rawUpdate("update tasks set title='$title' where Id=$id ");
  }

  Future<void> updateTaskDescription(int id, String description) async {
    Database _db = await database();
    await _db.rawUpdate("update tasks set description='$description' where Id=$id ");
  }

  Future<void> updateTaskDueDate(int id, String dueDate) async {
    Database _db = await database();
    await _db.rawUpdate("update tasks set dueDate='$dueDate' where Id=$id ");
  }

  Future<void> updateTaskPriority(int id, int priority) async {
    Database _db = await database();
    await _db.rawUpdate("update tasks set priority='$priority' where Id=$id ");
  }

  Future<void> deleteTask(int id) async {
    Database _db = await database();
    await _db.rawDelete("delete from tasks where id=$id");
    await _db.rawDelete("delete from todo where taskId=$id");
  }

  Future<void> deleteTodoTask(int id) async {
    Database _db = await database();
    await _db.rawDelete("delete from todo where id=$id");
  }

  Future<void> updateTodoDone(int id, int isDone) async {
    Database _db = await database();
    await _db.rawUpdate("update todo set isDone='$isDone' where Id=$id ");
  }

  Future<void> updateTaskDone(int id, int isDone) async {
    Database _db = await database();
    await _db.rawUpdate("update tasks set isDone=$isDone where Id=$id ");
  }

  Future<List<Task>> getTasks() async {
    Database _db = await database();
    List<Map<String, dynamic>> taskMap = await _db.rawQuery("SELECT * FROM tasks");
    return List.generate(taskMap.length, (index) {
      return Task(
          id: taskMap[index]["id"],
          title: taskMap[index]["title"],
          description: taskMap[index]["description"],
          dueDate: taskMap[index]["dueDate"],
          priority: taskMap[index]["priority"],
          isDone: taskMap[index]["isDone"],

      );
    });
  }

  Future<List<Todo>> getTodo(int taskId) async {
    Database _db = await database();
    List<Map<String, dynamic>> todoMap = await _db.rawQuery('SELECT * FROM todo where taskId=$taskId');
    return List.generate(todoMap.length, (index) {
      return Todo(
          id: todoMap[index]["id"],
          taskId: todoMap[index]["taskId"],
          title: todoMap[index]["title"],
          dueDate: todoMap[index]["dueDate"],
          priority: todoMap[index]["priority"],
          isDone: todoMap[index]["isDone"]);
    });
  }
}
