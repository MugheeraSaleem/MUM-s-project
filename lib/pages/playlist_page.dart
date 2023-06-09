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
import 'package:mum_s/pages/counselingPage.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: kAppBarColor,
        title: const Center(
          child: Text(
            'My Playlists',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 30.0),
          ),
        ),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8.0),
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
                          size: 40.0,
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
          height: MediaQuery.of(context).size.height >= 775.0
              ? MediaQuery.of(context).size.height
              : 775.0,
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
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            staggeredTiles: const [
              StaggeredTile.extent(2, 150.0),
              StaggeredTile.extent(2, 150.0),
              StaggeredTile.extent(2, 150.0),
            ],
            children: [
              buildTile(
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            clipper: MClipper(),
                            child: Image.asset(
                              "assets/focus.jpeg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Text(
                          'My Exercises',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0),
                        ),
                      ]),
                ),
                onTap: () {},
              ),
              buildTile(
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            clipper: MClipper(),
                            child: Image.asset(
                              "assets/counseling.jpg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Text(
                          'My Counseling',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0),
                        ),
                      ]),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => counselingPage(),
                    ),
                  );
                  c_class.checkInternet(context);
                },
              ),
              buildTile(
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            clipper: MClipper(),
                            child: Image.asset(
                              "assets/print.jpg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Text(
                          'My Media',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 24.0),
                        ),
                      ]),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
