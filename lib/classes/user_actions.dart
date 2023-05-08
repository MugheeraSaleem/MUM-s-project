import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

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
void getCurrentUser() async {
  try {
    final user = auth.currentUser;
    if (user != null) {
      final loggedInUser = user;
      print(loggedInUser.displayName);
      print(loggedInUser.email);
    }
  } catch (e) {
    print(e);
  }
}
