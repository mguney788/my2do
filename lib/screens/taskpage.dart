import 'dart:ui';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my2doapp/database_helper_fs.dart';
import 'package:my2doapp/googleAuth_helper.dart';
import 'package:my2doapp/models/task.dart';
import 'package:my2doapp/models/todo.dart';
import '../widgets.dart';

class TaskPage extends StatefulWidget {
  final Task task;

  TaskPage({@required this.task});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String _taskId = "";
  String _taskTitle = "";
  String _taskDescription = "";

  DatabaseHelper_fs _dbHelper = DatabaseHelper_fs();

  FocusNode _titleFocus;
  FocusNode _descFocus;
  FocusNode _dueDateFocus;
  FocusNode _priorityFocus;

  FocusNode _todoDescFocus;
  FocusNode _todoDueDateFocus;
  FocusNode _todoPriorityFocus;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _priorityController = TextEditingController(text: "1");

  TextEditingController _todoDescController = TextEditingController();
  TextEditingController _todoDueDateController = TextEditingController();
  TextEditingController _todoPriorityController = TextEditingController(text: "1");

  bool _contentVisible = false;

  @override
  void initState() {
    print("initState method ran");

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    _dueDateController.text = formatter.format(now);
    _todoDueDateController.text = formatter.format(now);
    print(_dueDateController.text);

    _titleFocus = FocusNode();
    _descFocus = FocusNode();
    _dueDateFocus = FocusNode();
    _priorityFocus = FocusNode();

    _todoDescFocus = FocusNode();
    _todoDueDateFocus = FocusNode();
    _todoPriorityFocus = FocusNode();

    if (widget.task != null) {
      _taskId = widget.task.id;
      _taskTitle = widget.task.title;
      _taskDescription = widget.task.description;
      _titleController.text = widget.task.title;
      _descController.text = widget.task.description;
      _dueDateController.text = widget.task.dueDate;
      _priorityController.text = widget.task.priority.toString();
      _contentVisible = true;
    } else
      _titleFocus.requestFocus();

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descFocus.dispose();
    _dueDateFocus.dispose();
    _priorityFocus.dispose();

    _todoDescFocus.dispose();
    _todoDueDateFocus.dispose();
    _todoPriorityFocus.dispose();

    _titleController.dispose();
    _descController.dispose();
    _dueDateController.dispose();
    _priorityController.dispose();

    _todoDescController.dispose();
    _todoDueDateController.dispose();
    _todoPriorityController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        iconSize: 32,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              //check if the field is not empty
                              if (value != "") {
                                //check if the task is null
                                if (widget.task == null) {
                                  Task _newTask = Task(
                                      email: GoogleAuthHelper.userEmail,
                                      title: value,
                                      description: "",
                                      dueDate: _dueDateController.text,
                                      priority: int.parse(_priorityController.text),
                                      isDone: 0);
                                  _taskId = await _dbHelper.insertTask(_newTask);
                                  print("New Task Id:$_taskId");
                                  setState(() {
                                    _taskTitle = value;
                                    _contentVisible = true;
                                  });
                                } else {
                                  print("Update the existing task");
                                  _dbHelper.updateTaskTitle(_taskId, value);
                                }
                                _descFocus.requestFocus();
                              }
                            },
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: "Enter Task Title",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(fontSize: 26.0, /*color: Color(0xFF211551),*/ fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: TextField(
                      focusNode: _descFocus,
                      onSubmitted: (value) async {
                        if (value != "") {
                          //check if the task is null
                          if (_taskId != "") {
                            print("taskid:$_taskId");
                            await _dbHelper.updateTaskDescription(_taskId, value);
                          }
                        }
                        _dueDateFocus.requestFocus();
                      },
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: "Description",
                        hintText: "Enter Description for the task",
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Visibility(
                      visible: _contentVisible,
                      child: Expanded(
                        child: DateTimePicker(
                            type: DateTimePickerType.date,
                            focusNode: _dueDateFocus,
                            dateMask: 'dd/MM/yyyy',
                            controller: _dueDateController,
                            //initialValue: _initialValue,
                            firstDate: DateTime(DateTime.monthsPerYear),
                            lastDate: DateTime(2100),
                            //icon: Icon(Icons.event),
                            dateLabelText: 'Due Date',
                            //locale: Locale('en', 'US'),
                            onChanged: (val) async {
                              if (val != "") {
                                //check if the task is null
                                if (_taskId != "") {
                                  await _dbHelper.updateTaskDueDate(_taskId, val);
                                  _priorityFocus.requestFocus();
                                }
                              }
                            }),
                      ),
                    ),
                    SizedBox(width: 15),
                    Visibility(
                      visible: _contentVisible,
                      child: Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            //icon: Icon(Icons.priority_high),
                          ),
                          value: _priorityController.text,
                          focusNode: _priorityFocus,
                          //icon: const Icon(Icons.priority_high),
                          iconSize: 34,
                          elevation: 16,
                          //style: const TextStyle(color: Colors.deepPurple),
                          onChanged: (String value) async {
                            await _dbHelper.updateTaskPriority(_taskId, int.parse(value));

                            setState(() {
                              _priorityController.text = value;
                              _todoDescFocus.requestFocus();
                            });
                          },
                          items: [
                            DropdownMenuItem(
                              child: Text("P1"),
                              value: "1",
                            ),
                            DropdownMenuItem(
                              child: Text("P2"),
                              value: "2",
                            ),
                            DropdownMenuItem(
                              child: Text("P3"),
                              value: "3",
                            ),
                            DropdownMenuItem(
                              child: Text("P4"),
                              value: "4",
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                  SizedBox(height: 15),
                  Visibility(
                    visible: _contentVisible,
                    child: FutureBuilder(
                      initialData: [],
                      future: _dbHelper.getTodos(_taskId),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: snapshot.data != null ? snapshot.data.length : 0,
                              itemBuilder: (context, index) {
                                return TodoWidget(
                                  text: snapshot.data[index].title,
                                  dueDate: snapshot.data[index].dueDate,
                                  priority: snapshot.data[index].priority,
                                  isDone: snapshot.data[index].isDone == 0 ? false : true,
                                  onDelete: () async {
                                    await _dbHelper.deleteTodoTask(_taskId, snapshot.data[index].id);
                                    setState(() {});
                                  },
                                  onUpdate: () async {
                                    if (snapshot.data[index].isDone == 0) {
                                      await _dbHelper.updateTodoDone(_taskId, snapshot.data[index].id, 1);
                                      final todoCompletedSnackBar = SnackBar(
                                          content: Text('The ToDo item was completed.'),
                                          action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () async {
                                                await _dbHelper.updateTodoDone(_taskId, snapshot.data[index].id, 0);
                                                setState(() {});
                                              }));
                                      ScaffoldMessenger.of(context).showSnackBar(todoCompletedSnackBar);
                                    } else {
                                      await _dbHelper.updateTodoDone(_taskId, snapshot.data[index].id, 0);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    }
                                    setState(() {});
                                  },
                                );
                              }),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Builder(builder: (context) {
                      return OutlinedButton.icon(
                          label: Text('Add new ToDo item'),
                          icon: Icon(Icons.add, size: 18),
                          onPressed: () {
                            _todoDescFocus.requestFocus();
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                focusNode: _todoDescFocus,
                                                controller: _todoDescController,
                                                onSubmitted: (val) async {
                                                  if (val != "") {
                                                    _todoDescController.text = val;
                                                    _todoDueDateFocus.requestFocus();
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  hintText: "Enter new ToDo item...",
                                                  border: InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Visibility(
                                            visible: _contentVisible,
                                            child: Expanded(
                                              child: DateTimePicker(
                                                  type: DateTimePickerType.date,
                                                  focusNode: _dueDateFocus,
                                                  dateMask: 'dd/MM/yyyy',
                                                  controller: _todoDueDateController,
                                                  //initialValue: _initialValue,
                                                  firstDate: DateTime(DateTime.monthsPerYear),
                                                  lastDate: DateTime(2100),
                                                  //icon: Icon(Icons.event),
                                                  dateLabelText: 'ToDo - Due Date',
                                                  //locale: Locale('en', 'US'),
                                                  onChanged: (val) async {
                                                    if (val != "") {
                                                      _todoDueDateController.text = val;
                                                      _todoPriorityFocus.requestFocus();
                                                    }
                                                  }),
                                            ),
                                          ),
                                          SizedBox(width: 15.0),
                                          Visibility(
                                            visible: _contentVisible,
                                            child: Expanded(
                                              child: DropdownButtonFormField<String>(
                                                decoration: InputDecoration(
                                                  labelText: 'ToDo - Priority',
                                                  //icon: Icon(Icons.priority_high),
                                                ),
                                                value: _todoPriorityController.text,
                                                focusNode: _priorityFocus,
                                                //icon: const Icon(Icons.priority_high),
                                                iconSize: 34,
                                                elevation: 16,
                                                //style: const TextStyle(color: Colors.deepPurple),
                                                onChanged: (String val) async {
                                                  if (val != "") {
                                                    setState(() {
                                                      _todoPriorityController.text = val;
                                                    });
                                                  }
                                                },
                                                items: [
                                                  DropdownMenuItem(
                                                    child: Text("P1"),
                                                    value: "1",
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text("P2"),
                                                    value: "2",
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text("P3"),
                                                    value: "3",
                                                  ),
                                                  DropdownMenuItem(
                                                    child: Text("P4"),
                                                    value: "4",
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 15.0),
                                          IconButton(
                                              icon: Icon(
                                                Icons.send,
                                              ),
                                              onPressed: () async {
                                                print("taskId:$_taskId");
                                                if (_taskId != "") {
                                                  if (_todoDescController.text == "") return;

                                                  Todo _newTodo = Todo(
                                                    title: _todoDescController.text,
                                                    dueDate: _todoDueDateController.text,
                                                    priority: int.parse(_todoPriorityController.text),
                                                    isDone: 0,
                                                    taskId: _taskId,
                                                  );

                                                  await _dbHelper.insertTodo(_taskId, _newTodo);

                                                  setDefaultValueForTodoElement();

                                                  Navigator.pop(context);

                                                  print("New Task has been created");
                                                  setState(() {
                                                    _todoDescFocus.requestFocus();
                                                  });
                                                }
                                              })
                                        ]),
                                      ],
                                    ),
                                  );
                                });
                          });
                    }),
                  ),
                ],
              ),
            ),
            /*Visibility(
              visible: _contentVisible,
              child: Positioned(
                bottom: 20.0,
                right: 20.0,
                child: GestureDetector(
                  onTap: () async {
                    if (_taskId != 0) {
                      await _dbHelper.deleteTask(_taskId);
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(color: Color(0xFFFE3577), borderRadius: BorderRadius.circular(20.0)),
                    child: Image(
                      image: AssetImage("assets/images/delete_icon.png"),
                    ),
                  ),
                ),
              ),
            )*/
          ],
        )),
      ),
    );
  }

  void setDefaultValueForTodoElement() {
    _todoDescController.text = "";
    _todoDueDateController.text = DateTime.now().toString();
    _todoPriorityController.text = "1";
  }
}
