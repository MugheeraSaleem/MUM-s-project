import 'package:mum_s/pages/music.dart';
import 'package:mum_s/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:mum_s/style/constants.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mum_s/pages/dashboard.dart';
import 'package:flutter/services.dart';
import 'package:mum_s/pages/exercises_page.dart';
import 'package:mum_s/pages/media_page.dart';
import 'package:mum_s/pages/counseling_page.dart';
import 'package:mum_s/utils/user_actions.dart';

late User? loggedInUser;
var usersCollection = FirebaseFirestore.instance.collection('Users');

ConnectivityClass c_class = ConnectivityClass();
final _auth = FirebaseAuth.instance;

final ScrollController playListPageController = ScrollController();

class dietPage extends StatefulWidget {
  const dietPage({Key? key}) : super(key: key);

  @override
  State<dietPage> createState() => _dietPageState();
}

class _dietPageState extends State<dietPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: kAppBarColor,
          title: Center(
            child: Text(
              'My Diet Chart',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          15)
                      .toDouble()),
            ),
          ),
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  right: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          4)
                      .toDouble()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  MaterialButton(
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.person,
                            color: kFloatingActionButtonColor,
                            size: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    20)
                                .toDouble(),
                          )),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );
                      c_class.checkInternet(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: DraggableFab(
          child: SizedBox(
            height: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    32.5)
                .toDouble(),
            width: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    32.5)
                .toDouble(),
            child: FloatingActionButton(
              backgroundColor: kFloatingActionButtonColor,
              child: Icon(
                size: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        17)
                    .toDouble(),
                Icons.logout,
                color: Colors.white,
              ),
              onPressed: () {
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
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.Colors.loginGradientStart,
                  Theme.Colors.loginGradientEnd
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 1.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          12)
                      .toDouble(),
                  right: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          12)
                      .toDouble(),
                  top: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          110)
                      .toDouble(),
                  bottom: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          110)
                      .toDouble()),
              child: Material(
                elevation: 14,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          50)
                      .toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Color(0x90E5D0EC),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Image.asset(
                      "assets/diet_img.png",
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
