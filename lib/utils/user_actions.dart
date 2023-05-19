import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;
final FirebaseAuth auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

// This method is used to create the user in firestore
// Future<void> createUser(String uid, String username, String email) async {
//   //Creates the user doc named whatever the user uid is in te collection "users"
//   //and adds the user data
//   await db.collection("users").doc(uid).set({'Name': username, 'Email': email});
// }

//This function registers a new user with auth and then calls the function createUser
Future<User?> registerUser(
    String email, String password, String username) async {
  //Create the user with auth
  UserCredential newUser = await auth.createUserWithEmailAndPassword(
      email: email, password: password);

  User? user = newUser.user;
  // User? currentUser = await auth.currentUser;
  await user?.updateDisplayName(username);

  // Create the user in firestore with the user data
  // createUser(newUser.user!.uid, username, email);
  return user;
}

//Function for logging in a user
Future<User> logIn(String email, String password) async {
  //sign in the user with auth and get the user auth info back
  User? user =
      (await auth.signInWithEmailAndPassword(email: email, password: password))
          .user;

  //Get the user doc with the uid of the user that just logged in
  DocumentReference ref = db.collection("users").doc(user!.uid);
  DocumentSnapshot snapshot = await ref.get();

  //Print the user's name or do whatever you want to do with it
  return user;
}

// This function is used to get the loggedIn user.
getCurrentUser() async {
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
    showInSnackBar('Unexpected error occurred', Colors.red, null, null);
    print(e);
    return;
  }
}

// purana code, doesnt work
// Future signInWithGoogle(SignInViewModel model) async {
//   model.state = ViewState.Busy;
//   GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//   GoogleSignInAuthentication googleSignInAuthentication =
//       await googleSignInAccount.authentication;
//   AuthCredential credential = GoogleAuthProvider.getCredential(
//     accessToken: googleSignInAuthentication.accessToken,
//     idToken: googleSignInAuthentication.idToken,
//   );
//   UserCredential authResult = await auth.signInWithCredential(credential);
//   User? user = authResult.user;
//   assert(user?.isAnonymous);
//   assert(await user.getIdToken() != null);
//   User currentUser = await auth.currentUser;
//   assert(user.uid == currentUser.uid);
//   model.state = ViewState.Idle;
//   print("User Name: ${user.displayName}");
//   print("User Email ${user.email}");
// }
