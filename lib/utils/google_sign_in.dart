import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSIgnIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  Future googleLogin() async {
    final googleUser = await googleSIgnIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final firebase_user =
        await FirebaseAuth.instance.signInWithCredential(credential);
    notifyListeners();
    // print('google user is hereeeeeeeeeeeee' + googleUser.toString());
    // print('firebase user is hereeeeeeeeeeeee' + firebase_user.toString());
    return googleUser;
  }
}
