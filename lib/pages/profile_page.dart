import 'package:mum_s/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mum_s/style/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

var usersCollection = FirebaseFirestore.instance.collection('Users');

late User? loggedInUser;
late int? age;
late int? height;
late int? weight;
late var photoURL;
late var parsedDate;
late String spouseName;

class ProfilePage extends StatefulWidget {
  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _status = true;

  final _auth = FirebaseAuth.instance;

  final FocusNode myFocusNodeDeliveryDate = FocusNode();
  final FocusNode myFocusNodeAge = FocusNode();
  final FocusNode myFocusNodeSpouseName = FocusNode();
  // final FocusNode myFocusNodeCity = FocusNode();
  final FocusNode myFocusNodeHeight = FocusNode();
  final FocusNode myFocusNodeWeight = FocusNode();

  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController spouseNameController = TextEditingController();
  // TextEditingController cityController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  ConnectivityClass c_class = ConnectivityClass();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    loggedInUser = getCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    myFocusNodeDeliveryDate.dispose();
    myFocusNodeAge.dispose();
    myFocusNodeSpouseName.dispose();
    myFocusNodeHeight.dispose();
    myFocusNodeWeight.dispose();

    deliveryDateController.dispose();
    ageController.dispose();
    spouseNameController.dispose();
    heightController.dispose();
    weightController.dispose();
    // mobileNumberController.dispose();

    super.dispose();
  }

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 80,
    );

    if (image == null) return;

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('Images');

    Reference referenceImageToUpload = referenceDirImages
        .child("${loggedInUser!.uid.toString()}_profile_pic.jpg");

    try {
      await referenceImageToUpload.putFile(File(image.path));

      referenceImageToUpload.getDownloadURL().then(
        (value) async {
          await loggedInUser!.updatePhotoURL(value);
        },
      );

      Map<String, dynamic> userData = {
        'photoURL': await referenceImageToUpload.getDownloadURL(),
      };

      await usersCollection
          .doc(loggedInUser!.displayName)
          .set(userData, SetOptions(merge: true))
          .then((_) => print('photoURL change = Success'))
          .catchError((error) => print('Failed: $error'));
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Your entire data from the database will be deleted. '
            'Are you sure you want to proceed?',
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _showAuthenticationDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAuthenticationDialog() {
    String password = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (_auth.currentUser!.providerData
            .any((userInfo) => userInfo.providerId == 'google.com')) {
          return AlertDialog(
            title: const Text('Are you sure?'),
            content: TextFormField(
              onChanged: (value) {
                password = value;
              },
              decoration: const InputDecoration(labelText: 'Type Yes'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Authenticate'),
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  // idhar krna hai google email verification
                  if (password == 'Yes') {
                    _deleteUserData();
                  } else {
                    showInSnackBar('Authentication failed', Colors.red, context,
                        _scaffoldKey.currentContext!);
                  }
                },
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Authenticate'),
            content: TextFormField(
              onChanged: (value) {
                password = value;
              },
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
              TextButton(
                child: const Text('Authenticate'),
                onPressed: () async {
                  Navigator.pop(context); // Close the dialog
                  if (await _authenticateUser(password)) {
                    _deleteUserData();
                  } else {
                    showInSnackBar('Authentication failed', Colors.red, context,
                        _scaffoldKey.currentContext!);
                  }
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<bool> _authenticateUser(String password) async {
    try {
      if (_auth.currentUser!.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        final googleSignInAccount = await _googleSignIn.signInSilently();
        final googleSignInAuthentication =
            await googleSignInAccount!.authentication;
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await _auth.currentUser!
            .reauthenticateWithCredential(googleAuthCredential);
        return true;
      } else {
        // Reauthenticate the user with their password
        AuthCredential credential = EmailAuthProvider.credential(
          email: _auth.currentUser!.email!,
          password: password,
        );
        await _auth.currentUser!.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (error) {
      return false;
    }
  }

  void _deleteUserData() async {
    try {
      // Delete user's data
      // ...

      _deleteDocument(loggedInUser!.displayName);
      print('user data deleted');
      // Sign out user
      // if (_auth.currentUser!.providerData
      //     .any((userInfo) => userInfo.providerId == 'google.com')) {
      //   await _googleSignIn.disconnect(); // Disconnect Google Sign-In
      // }

      try {
        await FirebaseAuth.instance.currentUser!.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          print(
              'The user must re-authenticate before this operation can be executed.');
        }
      }
    } catch (error) {
      showInSnackBar('Error deleting data', Colors.red, context,
          _scaffoldKey.currentContext!);
    }
  }

  Future<void> _deleteDocument(String? documentId) async {
    try {
      if (!context.mounted) return;
      c_class.checkInternet(context);

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/',
        (route) =>
            false, // This predicate ensures all previous routes are removed
      );
      showInSnackBar('Data deleted successfully', Colors.green, context,
          _scaffoldKey.currentContext!);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('user_id');
      await usersCollection.doc(documentId).delete();
      _auth.signOut();
      print('Document deleted successfully');
    } catch (error) {
      print('Error deleting document: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Profile',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          12)
                      .toDouble()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 95),
              child: MaterialButton(
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        Icons.delete,
                        color: kFloatingActionButtonColor,
                        size: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                20)
                            .toDouble(),
                      )),
                ),
                onPressed: () {
                  c_class.checkInternet(context);
                  _showDeleteDialog();
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: DraggableFab(
        child: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            backgroundColor: kFloatingActionButtonColor,
            child: const Icon(
              size: 35,
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () async {
              c_class.checkInternet(context);
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) =>
                    false, // This predicate ensures all previous routes are removed
              );
              showInSnackBar('Logged out Successfully', Colors.green, context,
                  _scaffoldKey.currentContext!);
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('user_id');
            },
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Theme.Colors.loginGradientStart,
                        Theme.Colors.loginGradientEnd
                      ],
                      begin: FractionalOffset(0.0, 0.0),
                      end: FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                height: 250.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Stack(fit: StackFit.loose, children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            StreamBuilder<Object>(
                                stream: usersCollection
                                    .doc(loggedInUser!.displayName)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    photoURL = snapshot.data['photoURL'];
                                    if (photoURL != null) {
                                      return CachedNetworkImage(
                                        imageUrl: photoURL,
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: 160.0,
                                          height: 160.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 80,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 10,
                                            color: kFloatingActionButtonColor,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 80,
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 160,
                                            color: kFloatingActionButtonColor,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return CachedNetworkImage(
                                        imageUrl:
                                            loggedInUser!.photoURL.toString(),
                                        imageBuilder:
                                            (context, imageProvider) =>
                                                Container(
                                          width: 160.0,
                                          height: 160.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                        placeholder: (context, url) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 80,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 10,
                                            color: kFloatingActionButtonColor,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 80,
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 160,
                                            color: kFloatingActionButtonColor,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    return CircleAvatar(
                                      backgroundColor: Colors.white,
                                      radius: 80,
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 160,
                                        color: kFloatingActionButtonColor,
                                      ),
                                    );
                                  }
                                })
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 110.0, right: 100.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                child: CircleAvatar(
                                  backgroundColor: kFloatingActionButtonColor,
                                  radius: 25.0,
                                  child: const Icon(
                                    Icons.add_a_photo_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                                onTap: () {
                                  pickUploadProfilePic();
                                },
                              )
                            ],
                          ),
                        ),
                      ]),
                    )
                  ],
                ),
              ),
              Container(
                color: const Color(0xffFFFFFF),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  _status ? _getEditIcon() : Container(),
                                ],
                              )
                            ],
                          )),
                      const Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Expected Delivery Date',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Flexible(
                                child: StreamBuilder<Object>(
                                    stream: usersCollection
                                        .doc(loggedInUser!.displayName)
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!
                                              .data()!
                                              .containsKey('deliveryDate') &&
                                          _status &&
                                          snapshot.data['deliveryDate']
                                              .toDate()
                                              .isAfter(DateTime.now())) {
                                        var date = snapshot.data['deliveryDate']
                                            .toDate();
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEAE9EE),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            width: 400,
                                            height: 30,
                                            child: Center(
                                              child: Text(
                                                "${date.day}-${date.month}-${date.year}",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return TextField(
                                          controller: deliveryDateController,
                                          focusNode: myFocusNodeDeliveryDate,
                                          decoration: const InputDecoration(
                                            hintText:
                                                "Enter Date in DD-MM-YYYY format",
                                          ),
                                          enabled: !_status,
                                          autofocus: !_status,
                                        );
                                      }
                                    }),
                              ),
                            ],
                          )),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Age',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: StreamBuilder<Object>(
                                  stream: usersCollection
                                      .doc(loggedInUser!.displayName)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!
                                            .data()!
                                            .containsKey('age') &&
                                        _status) {
                                      var userAge = snapshot.data['age'];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEAE9EE),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          width: 400,
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              "${userAge} Years",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return TextField(
                                        focusNode: myFocusNodeAge,
                                        controller: ageController,
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Enter your age in years."),
                                        enabled: !_status,
                                      );
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Spouse Name',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                              child: StreamBuilder<Object>(
                                  stream: usersCollection
                                      .doc(loggedInUser!.displayName)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!
                                            .data()!
                                            .containsKey('spouseName') &&
                                        _status) {
                                      var spouseName =
                                          snapshot.data['spouseName'];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEAE9EE),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          width: 400,
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              "$spouseName",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return TextField(
                                        controller: spouseNameController,
                                        focusNode: myFocusNodeSpouseName,
                                        decoration: const InputDecoration(
                                            hintText:
                                                "Enter your husband\'s/wife\'s name"),
                                        enabled: !_status,
                                      );
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.only(
                      //       left: 25.0, right: 25.0, top: 25.0),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.max,
                      //     children: <Widget>[
                      //       Column(
                      //         mainAxisAlignment: MainAxisAlignment.start,
                      //         mainAxisSize: MainAxisSize.min,
                      //         children: <Widget>[
                      //           Text(
                      //             'City',
                      //             style: TextStyle(
                      //                 fontSize: 16.0,
                      //                 fontWeight: FontWeight.bold),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Padding(
                      //     padding: const EdgeInsets.only(
                      //         left: 25.0, right: 25.0, top: 2.0),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.max,
                      //       children: <Widget>[
                      //         Flexible(
                      //           child: TextField(
                      //             focusNode: myFocusNodeCity,
                      //             controller: cityController,
                      //             decoration: const InputDecoration(
                      //                 hintText: "Enter your city name"),
                      //             enabled: !_status,
                      //           ),
                      //         ),
                      //       ],
                      //     )),
                      const Padding(
                          padding: EdgeInsets.only(
                              left: 25.0, right: 25.0, top: 25.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Height',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Weight',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 25.0, right: 25.0, top: 2.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: StreamBuilder<Object>(
                                    stream: usersCollection
                                        .doc(loggedInUser!.displayName)
                                        .snapshots(),
                                    builder: (context, AsyncSnapshot snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data!
                                              .data()!
                                              .containsKey('height') &&
                                          _status) {
                                        var userHeight =
                                            snapshot.data['height'];
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15.0),
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEAE9EE),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10.0),
                                              ),
                                            ),
                                            width: 400,
                                            height: 30,
                                            child: Center(
                                              child: Text(
                                                "${userHeight} cms",
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return TextField(
                                          focusNode: myFocusNodeHeight,
                                          controller: heightController,
                                          decoration: const InputDecoration(
                                              hintText: "in cms"),
                                          enabled: !_status,
                                        );
                                      }
                                    }),
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: StreamBuilder<Object>(
                                  stream: usersCollection
                                      .doc(loggedInUser!.displayName)
                                      .snapshots(),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data!
                                            .data()!
                                            .containsKey('weight') &&
                                        _status) {
                                      var userWeight = snapshot.data['weight'];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEAE9EE),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                          ),
                                          width: 400,
                                          height: 30,
                                          child: Center(
                                            child: Text(
                                              "${userWeight} Kgs",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return TextField(
                                        focusNode: myFocusNodeWeight,
                                        controller: weightController,
                                        decoration: const InputDecoration(
                                            hintText: "in kgs"),
                                        enabled: !_status,
                                      );
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ),
                      !_status ? _getActionButtons() : Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _getActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 45.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () async {
                  if (deliveryDateController.text.trim().isEmpty ||
                      ageController.text.trim().isEmpty ||
                      heightController.text.trim().isEmpty ||
                      weightController.text.trim().isEmpty ||
                      spouseNameController.text.trim().isEmpty) {
                    showInSnackBar(
                        'Please provide all the information for best experience',
                        Colors.red,
                        context,
                        _scaffoldKey.currentContext);
                  } else {
                    DateTime currentDate = DateTime.now();

                    var enteredDate =
                        deliveryDateController.text.trim().toString();

                    try {
                      parsedDate = DateFormat('dd-MM-yyyy').parse(enteredDate);
                    } catch (e) {
                      print(e);
                      parsedDate = null;
                    }

                    if (parsedDate != null && parsedDate.isAfter(currentDate)) {
                      print(parsedDate);

                      print('datetime parser working');
                    } else if (parsedDate == null ||
                        parsedDate.isBefore(currentDate)) {
                      print('here');
                      showInSnackBar('Please provide a valid date', Colors.red,
                          context, _scaffoldKey.currentContext);
                    }

                    if (int.tryParse(ageController.text.trim().toString()) !=
                            null &&
                        int.tryParse(heightController.text.trim().toString()) !=
                            null &&
                        int.tryParse(weightController.text.trim().toString()) !=
                            null) {
                      age = int.tryParse(ageController.text.trim().toString());
                      weight =
                          int.tryParse(weightController.text.trim().toString());
                      height =
                          int.tryParse(heightController.text.trim().toString());
                    }

                    if (parsedDate != null &&
                        parsedDate.isAfter(currentDate) &&
                        num.tryParse(ageController.text.trim().toString()) !=
                            null &&
                        num.tryParse(weightController.text.trim().toString()) !=
                            null &&
                        num.tryParse(heightController.text.trim().toString()) !=
                            null &&
                        int.tryParse(ageController.text.trim().toString()) !=
                            null &&
                        int.tryParse(heightController.text.trim().toString()) !=
                            null &&
                        int.tryParse(weightController.text.trim().toString()) !=
                            null &&
                        age! >= 15 &&
                        age! < 76 &&
                        height! >= 105 &&
                        height! < 201 &&
                        weight! >= 35 &&
                        weight! < 116) {
                      Map<String, dynamic> userData = {
                        'deliveryDate': parsedDate,
                        'age': age,
                        'weight': weight,
                        'height': height,
                        'spouseName':
                            spouseNameController.text.trim().toString(),
                        'deliveryDateInfo': 'Delivery date set.'
                      };

                      UpdateData().updateData(userData);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(),
                        ),
                      );
                    } else {
                      if (num.tryParse(ageController.text.trim().toString()) ==
                          null) {
                        showInSnackBar('Please provide a valid Age', Colors.red,
                            context, _scaffoldKey.currentContext);
                      } else if (num.tryParse(
                              heightController.text.trim().toString()) ==
                          null) {
                        showInSnackBar('Please provide a valid Height',
                            Colors.red, context, _scaffoldKey.currentContext);
                      } else if (num.tryParse(
                              weightController.text.trim().toString()) ==
                          null) {
                        showInSnackBar('Please provide a valid Weight',
                            Colors.red, context, _scaffoldKey.currentContext);
                      }
                    }
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  setState(
                    () {
                      _status = true;
                      FocusScope.of(context).requestFocus(
                        FocusNode(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getEditIcon() {
    return GestureDetector(
      child: CircleAvatar(
        backgroundColor: kFloatingActionButtonColor,
        radius: 25.0,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 25.0,
        ),
      ),
      onTap: () {
        setState(() {
          _status = false;
        });
      },
    );
  }
}

class UpdateData {
  updateData(userData) async {
    await usersCollection
        .doc(loggedInUser!.displayName)
        .set(userData, SetOptions(merge: true))
        .then((_) => print('age/weight/height change = Success'))
        .catchError((error) => print('Failed: $error'));
  }
}
