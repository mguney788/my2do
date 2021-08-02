import 'package:flutter/material.dart';
import 'package:my2doapp/models/userDetails.dart';
import 'package:my2doapp/screens/homepage.dart';
import '../googleAuth_helper.dart';
import '../widgets.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RoundedRaisedButton(
                    size: size,
                    press: () async {
                      UserDetails userDetails = await GoogleAuthHelper.signIn(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Homepage(userDetails),
                        ),
                      );
                    },
                    icon: "assets/icons/googleIcon30px.png",
                    text: "Sing in with Google",
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}