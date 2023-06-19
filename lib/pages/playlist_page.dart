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

class PlaylistPage extends StatefulWidget {
  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    loggedInUser = getCurrentUser();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: kAppBarColor,
        title: Center(
          child: Text(
            'My Playlists',
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
      body: SingleChildScrollView(
        controller: playListPageController,
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
                tileMode: TileMode.clamp),
          ),
          child: StaggeredGridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    6)
                .toDouble(),
            mainAxisSpacing: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    6)
                .toDouble(),
            padding: EdgeInsets.symmetric(
                horizontal: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        8)
                    .toDouble(),
                vertical: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        4)
                    .toDouble()),
            staggeredTiles: [
              StaggeredTile.extent(
                  2,
                  ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          75)
                      .toDouble()),
              StaggeredTile.extent(
                  2,
                  ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          75)
                      .toDouble()),
              StaggeredTile.extent(
                  2,
                  ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          75)
                      .toDouble()),
            ],
            children: [
              buildTile(
                StreamBuilder<Object>(
                    stream: usersCollection
                        .doc(loggedInUser!.displayName)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!
                              .data()!
                              .containsKey('Exercises last watched video')) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/focus.jpeg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Exercises',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                    ),
                                    Text(
                                      'Last watching: ${snapshot.data['Exercises last watched video']}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  7.5)
                                              .toDouble()),
                                    ),
                                  ],
                                ),
                              ]),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/focus.jpeg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Text(
                                  'My Exercises',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          ((MediaQuery.of(context).size.height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                ),
                              ]),
                        );
                      }
                    }),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExercisesPage(),
                    ),
                  );
                  c_class.checkInternet(context);
                },
              ),
              buildTile(
                StreamBuilder<Object>(
                    stream: usersCollection
                        .doc(loggedInUser!.displayName)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!
                              .data()!
                              .containsKey('Counseling last watched video')) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/counseling.jpg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'My Counseling',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                    ),
                                    Text(
                                      'Last watching: ${snapshot.data['Counseling last watched video']}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  7.5)
                                              .toDouble()),
                                    ),
                                  ],
                                ),
                              ]),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/counseling.jpg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Text(
                                  'My Counseling',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          ((MediaQuery.of(context).size.height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                ),
                              ]),
                        );
                      }
                    }),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CounselingPage(),
                    ),
                  );
                  c_class.checkInternet(context);
                },
              ),
              buildTile(
                StreamBuilder<Object>(
                    stream: usersCollection
                        .doc(loggedInUser!.displayName)
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data!
                              .data()!
                              .containsKey('Media last watched video')) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/print.jpg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'My Media',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                    ),
                                    Text(
                                      'Last watching: ${snapshot.data['Media last watched video']}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  7.5)
                                              .toDouble()),
                                    ),
                                  ],
                                ),
                              ]),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      9)
                                  .toDouble()),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  radius: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          35)
                                      .toDouble(),
                                  backgroundColor: Colors.white,
                                  child: ClipOval(
                                    clipper: MClipper(),
                                    child: Image.asset(
                                      "assets/print.jpg",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Text(
                                  'My Media',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize:
                                          ((MediaQuery.of(context).size.height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  12)
                                              .toDouble()),
                                ),
                              ]),
                        );
                      }
                    }),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MediaPage(),
                    ),
                  );
                  c_class.checkInternet(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
