import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mum_s/pages/dashboard.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

//This function registers a new user with auth and then calls the function createUser
Future<User?> registerUser(
  String email,
  String password,
  String username,
) async {
  //Create the user with auth
  UserCredential newUser = await auth.createUserWithEmailAndPassword(
      email: email, password: password);

  User? user = newUser.user;
  // User? currentUser = await auth.currentUser;
  await user?.updateDisplayName(username);

  //TODO: Create the user in firestore-collection as well with the user data while the user signs-up
  return user;
}

//Function for logging in a user
Future<User?> logIn(String email, String password) async {
  //sign in the user with auth and get the user auth info back
  User? user =
      (await auth.signInWithEmailAndPassword(email: email, password: password))
          .user;
  return user;
}

// This function is used to get the loggedIn user.
User getCurrentUser() {
  try {
    final user = auth.currentUser;
    if (user != null) {
      final loggedInUser = user;
      print(loggedInUser.displayName);
      print(loggedInUser.email);
      print(loggedInUser.photoURL);
      return loggedInUser;
    }
  } catch (e) {
    showInSnackBar(
      'Unexpected error occurred',
      Colors.red,
      null,
      null,
    );
    print(e);
    return loggedInUser;
  }
  return loggedInUser;
}

// This function is used to send the reset password emails to the user
Future? resetPassword(email, scaffoldKey, context) async {
  try {
    await auth.sendPasswordResetEmail(
      email: email,
    );
    showInSnackBar('Check your valid email to reset password', Colors.green,
        scaffoldKey, context);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      showInSnackBar(
        'Please provide a valid email',
        Colors.red,
        context,
        scaffoldKey,
      );
    } else if (e.code == 'user-not-found') {
      showInSnackBar(
        'User not found',
        Colors.red,
        context,
        scaffoldKey,
      );
    } else {
      print(e);
      showInSnackBar(
        e.toString(),
        Colors.red,
        context,
        scaffoldKey,
      );
    }
  }
}
