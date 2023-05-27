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

late User loggedInUser;

late var deliveryDate;
late var age;
late var mobileNumer;
late var city;
late var height;
late var weight;

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
  final FocusNode myFocusNodeMobileNumber = FocusNode();
  // final FocusNode myFocusNodeCity = FocusNode();
  final FocusNode myFocusNodeHeight = FocusNode();
  final FocusNode myFocusNodeWeight = FocusNode();

  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  // TextEditingController cityController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  ConnectivityClass c_class = ConnectivityClass();

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
    // myFocusNodeCity.dispose();
    myFocusNodeHeight.dispose();
    myFocusNodeWeight.dispose();

    deliveryDateController.dispose();
    ageController.dispose();
    // cityController.dispose();
    heightController.dispose();
    weightController.dispose();
    mobileNumberController.dispose();

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
        .child("${loggedInUser.displayName.toString()}_profile_pic.jpg");

    try {
      await referenceImageToUpload.putFile(File(image.path));

      referenceImageToUpload.getDownloadURL().then(
        (value) {
          loggedInUser.updatePhotoURL(value);
          setState(() {});
        },
      );
    } catch (e) {
      print(e);
    }
  }

  updatePicture() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: const Text(
          'Background Information',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 26.0),
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
            onPressed: () {
              c_class.checkInternet(context);
              _auth.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
              showInSnackBar('Logged out Successfully', Colors.green, context,
                  _scaffoldKey.currentContext!);
            },
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
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
                              CachedNetworkImage(
                                imageUrl: loggedInUser.photoURL.toString(),
                                imageBuilder: (context, imageProvider) =>
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
                                placeholder: (context, url) => CircleAvatar(
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
                              )
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
                                  child: TextField(
                                    controller: deliveryDateController,
                                    focusNode: myFocusNodeDeliveryDate,
                                    decoration: const InputDecoration(
                                      hintText:
                                          "Enter Date in DD/MM/YYYY format",
                                    ),
                                    enabled: !_status,
                                    autofocus: !_status,
                                  ),
                                ),
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
                                child: TextField(
                                  focusNode: myFocusNodeAge,
                                  controller: ageController,
                                  decoration: const InputDecoration(
                                      hintText: "Enter your age in years."),
                                  enabled: !_status,
                                ),
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
                        //             'Mobile',
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
                        //             controller: mobileNumberController,
                        //             focusNode: myFocusNodeMobileNumber,
                        //             decoration: const InputDecoration(
                        //                 hintText: "Enter Mobile Number"),
                        //             enabled: !_status,
                        //           ),
                        //         ),
                        //       ],
                        //     )),
                        // // const Padding(
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
                                  child: TextField(
                                    focusNode: myFocusNodeHeight,
                                    controller: heightController,
                                    decoration: const InputDecoration(
                                        hintText: "in cms"),
                                    enabled: !_status,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 2,
                                child: TextField(
                                  focusNode: myFocusNodeWeight,
                                  controller: weightController,
                                  decoration:
                                      const InputDecoration(hintText: "in kgs"),
                                  enabled: !_status,
                                ),
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
                onPressed: () {
                  if (deliveryDateController.text.trim().isEmpty ||
                      ageController.text.trim().isEmpty ||
                      mobileNumberController.text.trim().isEmpty ||
                      // cityController.text.trim().isEmpty ||
                      heightController.text.trim().isEmpty ||
                      weightController.text.trim().isEmpty) {
                    showInSnackBar(
                        'Please provide all the information for best experience.',
                        Colors.red,
                        context,
                        _scaffoldKey.currentContext);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MainPage(),
                      ),
                    );
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
