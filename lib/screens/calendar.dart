import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:my2doapp/models/task.dart';
import 'package:my2doapp/screens/taskpage.dart';
import "package:collection/collection.dart";

import '../database_helper_fs.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CalendarPage();
  }
}

class _CalendarPage extends State<CalendarPage> {
  DatabaseHelper_fs _dbHelper = DatabaseHelper_fs();
  Map<DateTime, List<NeatCleanCalendarEvent>> _events;

  @override
  void initState() {
    _events = generateEvents();
    super.initState();
  }

  Map<DateTime, List<NeatCleanCalendarEvent>> generateEvents() {
    List<NeatCleanCalendarEvent> _neatCleanCalendarEvents = [];
    Map<DateTime, List<NeatCleanCalendarEvent>> r = {};
    List<Task> tasks = [];

    _dbHelper.getTasks().then((element) {
      element.forEach((element) {
        var d = DateTime.now();
        tasks.add(element);
      });
    }).whenComplete(() {
      var newMap = groupBy(tasks, (obj) => obj.dueDate);
      newMap.forEach((k, tasks) {
        DateTime dueDate = DateTime.parse(k);
        List<NeatCleanCalendarEvent> events = [];
        tasks.forEach((element) {
          print(element.title);
          var event = NeatCleanCalendarEvent(
            "Summary: " + element.title + " | Priority: " + element.priority.toString(),
            description: "Description: " + element.description,
            startTime: dueDate,
            endTime: dueDate,
            color: Colors.brown,
            location: element.id,
          );
          var eventSummary = event.summary;
          events.add(event);
        });
        r[dueDate] = events;
      });
      setState(() {});
    });
    return r;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            Expanded(
              child: Center(child: Text("Calendar")),
            ),
            SizedBox(width: 20,)
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Calendar(
            startOnMonday: true,
            weekDays: ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'],
            events: _events,
            isExpandable: true,
            eventDoneColor: Colors.green,
            selectedColor: Colors.pink,
            todayColor: Colors.blue,
            eventColor: Colors.grey,
            locale: Localizations.localeOf(context).toString(),
            todayButtonText: '',
            expandableDateFormat: 'EEEE, dd. MMMM yyyy',
            onEventSelected: (value) {
              Task task;
              _dbHelper.getTask(value.location).then((value) => task = value).whenComplete(() {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TaskPage(task: task))).then((value) =>  setState(() {}));
              });
            },
            dayOfWeekStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
          ),
        ),
      ),
    );
  }
}
