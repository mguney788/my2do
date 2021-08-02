import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'package:my2doapp/database_helper_fs.dart';
import 'package:my2doapp/googleAuth_helper.dart';
import 'package:my2doapp/models/task.dart';
import 'package:my2doapp/models/userDetails.dart';
import 'package:my2doapp/screens/taskpage.dart';
import 'package:my2doapp/widgets.dart';
import '../widgets.dart';
import 'calendar.dart';

enum MenuItem { AllTasks, DoneTasks, OpenTasks }

class Homepage extends StatefulWidget {
  final UserDetails userDetails;

  Homepage([this.userDetails]);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DatabaseHelper_fs _dbHelper = DatabaseHelper_fs();
  Future<List<Task>> tasks;
  MenuItem menuItem = MenuItem.AllTasks;
  String selectedMenuItemText = "";
  SearchBar searchBar;

  @override
  void initState() {
    menuItem = MenuItem.OpenTasks;
    getTasksByMenuItem();

    searchBar = new SearchBar(
        inBar: false,
        buildDefaultAppBar: buildAppBar,
        setState: setState,
        onSubmitted: onSubmitted,
        onCleared: () {
          print("cleared");
        },
        onClosed: () {
          print("closed");
        });

    super.initState();
  }

  void getTasksByMenuItem() {
    if (menuItem == MenuItem.AllTasks) {
      selectedMenuItemText = "All Tasks";
      tasks = _dbHelper.getTasks();
    } else if (menuItem == MenuItem.OpenTasks) {
      selectedMenuItemText = "Open Tasks";
      tasks = _dbHelper.getOpenTasks();
    } else if (menuItem == MenuItem.DoneTasks) {
      selectedMenuItemText = "Done Tasks";
      tasks = _dbHelper.getDoneTasks();
    }
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Expanded(
              child: Center(child: Text(selectedMenuItemText)),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.date_range),
              tooltip: "Calendar",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()),
                );
              }),
          SizedBox(
            width: 5,
          ),
          searchBar.getSearchAction(context),
          SizedBox(
            width: 5,
          ),
        ]);
  }

  void onSubmitted(String value) {
    tasks = _dbHelper.getSearchResult(value);
    selectedMenuItemText = "Search Result";
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(content: new Text('You wrote $value!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.userDetails.photoUrl),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(widget.userDetails.userName),
                  SizedBox(
                    height: 10,
                  ),
                  IconButton(
                      onPressed: () {
                        print("signOut");
                        GoogleAuthHelper.signOut(context: context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.exit_to_app_outlined,
                      )),
                ],
              ),
              decoration: BoxDecoration(),
            ),
            ListTile(
              title: Text('All Tasks'),
              onTap: () {
                menuItem = MenuItem.AllTasks;
                getTasksByMenuItem();
                setState(() {});
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Done Tasks'),
              onTap: () {
                menuItem = MenuItem.DoneTasks;
                getTasksByMenuItem();
                setState(() {});
                Navigator.pop(context);
                // ...
              },
            ),
            ListTile(
              title: Text('Open Tasks'),
              onTap: () {
                menuItem = MenuItem.OpenTasks;
                getTasksByMenuItem();
                setState(() {});
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: searchBar.build(context),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          color: Color(0xFFF6F6F6),
          child: Stack(
            children: [
              ScrollConfiguration(
                  behavior: NoGlowBehavior(),
                  child: FutureBuilder(
                    initialData: [],
                    future: tasks,
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data != null ? snapshot.data.length : 0,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            background: Container(color: Colors.red),
                            onDismissed: (direction) {
                              _dbHelper.deleteTask(snapshot.data[index].id);
                            },
                            key: UniqueKey(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (snapshot.data[index].isDone == 0) {
                                      await _dbHelper.updateTaskDone(snapshot.data[index].id, 1);
                                      final taskCompletedSnackBar = SnackBar(
                                          content: Text('The Task item was completed.'),
                                          action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () async {
                                                await _dbHelper.updateTaskDone(snapshot.data[index].id, 0);
                                                setState(() {});
                                              }));
                                      ScaffoldMessenger.of(context).showSnackBar(taskCompletedSnackBar);
                                    } else {
                                      await _dbHelper.updateTaskDone(snapshot.data[index].id, 0);
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    }
                                    setState(() {});
                                    getTasksByMenuItem();
                                  },
                                  child: Container(
                                      width: 20,
                                      height: 20,
                                      margin: EdgeInsets.only(right: 14.0),
                                      decoration: BoxDecoration(
                                          color: snapshot.data[index].isDone == 1 ? Colors.indigo : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: snapshot.data[index].isDone == 1 ? null : Border.all(color: Color(0xFF86829D), width: 1.5)),
                                      child: Image(image: AssetImage("assets/images/check_icon.png"))),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskPage(task: snapshot.data[index]))).then((value) {
                                        getTasksByMenuItem();
                                        setState(() {});
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: TaskCardWidget(
                                        title: snapshot.data[index].title,
                                        desc: snapshot.data[index].description,
                                        dueDate: snapshot.data[index].dueDate,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  )),
              Positioned(
                bottom: 20.0,
                right: 20.0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TaskPage(task: null))).then((value) {
                      menuItem = MenuItem.OpenTasks;
                      getTasksByMenuItem();
                      setState(() {});
                    });
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(20.0)),
                    child: Image(
                      image: AssetImage("assets/images/add_icon.png"),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
