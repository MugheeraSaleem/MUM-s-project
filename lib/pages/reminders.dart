import 'package:flutter/material.dart';
import 'forum.dart';
import 'package:mum_s/pages/profile_page.dart';
import 'package:mum_s/style/constants.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:cloud_firestore/cloud_firestore.dart';

class RemindersPage extends StatefulWidget {
  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  ConnectivityClass c_class = ConnectivityClass();
  final _auth = FirebaseAuth.instance;

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
                        17.5)
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
          leading: IconButton(
            color: Colors.black,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            'Reminders',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        15)
                    .toDouble()),
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(
                  right: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          0)
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
            child: ListView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 54.0),
                    child: Material(
                      elevation: 8.0,
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(32.0),
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.add, color: Colors.white),
                              Padding(padding: EdgeInsets.only(right: 16.0)),
                              Text('ADD AN APPOINTMENT',
                                  style: TextStyle(color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                    )),
                ShopItem(),
                BadShopItem(),
                NewShopItem()
              ],
            ),
          ),
        ));
  }
}

class ShopItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: <Widget>[
          /// Item card
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
                size: const Size.fromHeight(172.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    /// Item description inside a material
                    Container(
                      margin: const EdgeInsets.only(top: 24.0),
                      child: Material(
                        elevation: 14.0,
                        borderRadius: BorderRadius.circular(12.0),
                        shadowColor: const Color(0x802196F3),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => ItemReviewsPage())),
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /// Title and rating
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Monthly Checkup',
                                        style: TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 15.0)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Dr. Uzma',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 34.0)),
                                      ],
                                    ),
                                  ],
                                ),

                                /// Infos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Scheduled', style: TextStyle()),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text('Tomorrow',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Item image
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(54.0),
                          child: Material(
                            elevation: 20.0,
                            shadowColor: const Color(0x802196F3),
                            shape: const CircleBorder(),
                            child: Image.asset('assets/shoes1.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),

          /// Review
          Padding(
            padding: const EdgeInsets.only(top: 160.0, left: 32.0),
            child: Material(
              elevation: 12.0,
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFF84fab0), Color(0xFF8fd3f4)],
                        end: Alignment.topLeft,
                        begin: Alignment.bottomRight)),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text('GR'),
                    ),
                    title: Text('Gangaram Hospital', style: TextStyle()),
                    subtitle: Text('Karol Bagh, New Delhi - 110096',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle()),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BadShopItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Stack(
        children: <Widget>[
          /// Item card
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox.fromSize(
                size: const Size.fromHeight(172.0),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    /// Item description inside a material
                    Container(
                      margin: const EdgeInsets.only(top: 24.0),
                      child: Material(
                        elevation: 14.0,
                        borderRadius: BorderRadius.circular(12.0),
                        shadowColor: const Color(0x802196F3),
                        color: Colors.transparent,
                        child: Container(
                          decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Color(0xFFDA4453),
                            Color(0xFF89216B)
                          ])),
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /// Title and rating
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Vaccination',
                                        style: TextStyle(color: Colors.white)),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text('Hepatitis B',
                                            style: TextStyle(
                                                color: Colors.amber,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 34.0)),
                                      ],
                                    ),
                                  ],
                                ),

                                /// Infos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text('Due By: 28/09/19',
                                        style: TextStyle(color: Colors.white)),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text('',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// Item image
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: SizedBox.fromSize(
                          size: const Size.fromRadius(54.0),
                          child: Material(
                            elevation: 20.0,
                            shadowColor: const Color(0x802196F3),
                            shape: const CircleBorder(),
                            child: Image.asset('assets/shoes1.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),

          /// Review
          Padding(
            padding: const EdgeInsets.only(
              top: 160.0,
              right: 32.0,
            ),
            child: Material(
              elevation: 12.0,
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: const ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text('HB'),
                  ),
                  title: Text('Intramuscular'),
                  subtitle: Text('Antero lateral side of mid thigh',
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class NewShopItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox.fromSize(
            size: const Size.fromHeight(172.0),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                /// Item description inside a material
                Container(
                  margin: const EdgeInsets.only(top: 24.0),
                  child: Material(
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(12.0),
                    shadowColor: const Color(0x802196F3),
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /// Title and rating
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('[New] Post',
                                  style: TextStyle(color: Colors.blueAccent)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text('Not published',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 34.0)),
                                ],
                              ),
                            ],
                          ),

                          /// Infos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text('Viewed by', style: TextStyle()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text('0',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                /// Item image
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: SizedBox.fromSize(
                      size: const Size.fromRadius(54.0),
                      child: Material(
                        elevation: 20.0,
                        shadowColor: const Color(0x802196F3),
                        shape: const CircleBorder(),
                        child: Image.asset('assets/shoes1.png'),
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
