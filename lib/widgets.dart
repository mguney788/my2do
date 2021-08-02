import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/priority.dart';

class TaskCardWidget extends StatelessWidget {
  final String title;
  final String desc;
  final String dueDate;

  TaskCardWidget({this.title, this.desc, this.dueDate});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 20.0),
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 14.0),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title ?? "(Unnamed Task)", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(desc ?? "No Description Added.", style: TextStyle(fontSize: 18.0, height: 1.5)),
            ),
            Text(DateFormat("dd/MM/yyyy").format(DateTime.parse(dueDate)))
          ],
        ));
  }
}

class TodoWidget extends StatelessWidget {
  final String text;
  final String dueDate;
  final int priority;
  final bool isDone;

  TodoWidget({this.text, this.dueDate, this.priority, @required this.isDone, this.onUpdate, this.onDelete});

  final Function onUpdate;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    final AlertDialog deleteDialog = AlertDialog(
      title: Text('DELETE ?'),
      content: Text('Do you want to delete this ToDo item?'),
      actions: [
        FlatButton(
          textColor: Colors.indigo,
          onPressed: () => Navigator.pop(context),
          child: Text('No'),
        ),
        FlatButton(
          textColor: Colors.indigo,
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          child: Text('Yes'),
        ),
      ],
    );
    return Card(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 1),
        child: Row(
          children: [
            InkWell(
              onTap: onUpdate,
              child: Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(right: 12.0),
                  decoration: BoxDecoration(
                      color: isDone ? Colors.indigo : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.0),
                      border: isDone ? null : Border.all(color: Color(0xFF86829D), width: 1.5)),
                  child: Image(image: AssetImage("assets/images/check_icon.png"))),
            ),
            Container(
              width: 150,
              child: Text(
                text ?? "(Unnamed Todo)",
                style: TextStyle(
                  decoration: isDone ?TextDecoration.lineThrough:null,
                  color: isDone ? Color(0xFF211551) : Color(0xFF86829D),
                  fontSize: 14.0,
                  //fontWeight: isDone ? FontWeight.bold : FontWeight.w500,

                ),
              ),
            ),
            Spacer(),
            Text(
              DateFormat("dd/MM/yyyy").format(DateTime.parse(dueDate)),
              style: TextStyle(
                decoration: isDone ?TextDecoration.lineThrough:null,
                color: isDone ? Color(0xFF211551) : Color(0xFF86829D),
                fontSize: 14.0,
                //fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              Priority.getPriorityText(priority),
              style: TextStyle(
                decoration: isDone ?TextDecoration.lineThrough:null,
                color: isDone ? Color(0xFF211551) : Color(0xFF86829D),
                fontSize: 14.0,
                //fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            Spacer(),
            IconButton(
                icon: Icon(Icons.delete),
                color: Colors.indigo,
                onPressed: () {
                  showDialog<void>(context: context, builder: (context) => deleteDialog);
                }),
          ],
        ),
      ),
    );
  }
}

class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class RoundedRaisedButton extends StatelessWidget {
  const RoundedRaisedButton({
    Key key,
    @required this.size,
    this.text,
    this.icon,
    this.press,
  }) : super(key: key);

  final Size size;
  final String text;
  final String icon;
  final Function press;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * 0.6,
      child: RaisedButton(
        onPressed: press,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.asset(
              icon,
            ),
            SizedBox(
              width: 20,
            ),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
