import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'models/userDetails.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class GoogleAuthHelper {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = new GoogleSignIn();
  static String userEmail="";

  static Future<UserDetails> signIn(BuildContext context) async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    userEmail=googleUser.email;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _firebaseAuth.signInWithCredential(credential)).user;
    final providerInfo = new ProviderDetails(user.uid);

    List<ProviderDetails> providerData = new List<ProviderDetails>();
    providerData.add(providerInfo);

    UserDetails details = new UserDetails(user.uid, user.displayName, user.photoUrl, user.email, providerData);
    //print("Signed In " + user.displayName);
    return details;
  }

  static Future<void> signOut({@required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
    await FirebaseAuth.instance.signOut();
  }
}
