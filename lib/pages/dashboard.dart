import 'package:mum_s/pages/map.dart';
import 'package:mum_s/pages/music.dart';
import 'package:mum_s/pages/playlist_page.dart';
import 'package:mum_s/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mum_s/style/constants.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mum_s/pages/reminders.dart';
import 'package:mum_s/pages/diet_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late User? loggedInUser;
var usersCollection = FirebaseFirestore.instance.collection('Users');

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static final List<String> chartDropdownItems = [
    'Last 7 days',
    'Last month',
    'Last year'
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String actualDropdown = chartDropdownItems[0];
  int actualChart = 0;

  ConnectivityClass c_class = ConnectivityClass();
  final _auth = FirebaseAuth.instance;
  final ScrollController dashboardController = ScrollController();

  @override
  void initState() {
    c_class.getConnectivity(context);
    c_class.checkInternet(context);
    // This function is printing the users name and its email
    loggedInUser = getCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    dashboardController.dispose();
    c_class.subscription.cancel();
    super.dispose();
  }

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
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2.0,
          backgroundColor: kAppBarColor,
          title: Padding(
            padding: EdgeInsets.only(
                left: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        45)
                    .toDouble()),
            child: Text(
              'Dashboard',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          12)
                      .toDouble()),
            ),
          ),
          actions: <Widget>[
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
          controller: dashboardController,
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
                            55)
                        .toDouble()),
                StaggeredTile.extent(
                    1,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            90)
                        .toDouble()),
                StaggeredTile.extent(
                    1,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            90)
                        .toDouble()),
                StaggeredTile.extent(
                    2,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            110)
                        .toDouble()),
                StaggeredTile.extent(
                    2,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            55)
                        .toDouble()),
                StaggeredTile.extent(
                    2,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            55)
                        .toDouble()),
                StaggeredTile.extent(
                    2,
                    ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            55)
                        .toDouble()),
              ],
              children: <Widget>[
                buildTile(
                  Padding(
                    padding: EdgeInsets.all(
                        ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12)
                            .toDouble()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Months and Days left',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize:
                                      ((MediaQuery.of(context).size.height /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              7.5)
                                          .toDouble()),
                            ),
                            StreamBuilder<Object>(
                                stream: usersCollection
                                    .doc(loggedInUser!.displayName)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  DateTime now = DateTime.now();
                                  if (snapshot.hasData &&
                                      snapshot.data!
                                          .data()!
                                          .containsKey('deliveryDate') &&
                                      (snapshot.data['deliveryDate'].toDate().month -
                                              now.month) >
                                          0 &&
                                      (snapshot.data['deliveryDate'].toDate().day - now.day) >
                                          0) {
                                    return Text(
                                      '${snapshot.data['deliveryDate'].toDate().month - now.month} months/${snapshot.data['deliveryDate'].toDate().day - now.day} days',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  10)
                                              .toDouble()),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!
                                          .data()!
                                          .containsKey('deliveryDate') &&
                                      (snapshot.data['deliveryDate'].toDate().month -
                                              now.month) >
                                          0 &&
                                      (snapshot.data['deliveryDate'].toDate().day -
                                              now.day) <
                                          0) {
                                    return Text(
                                      '${snapshot.data['deliveryDate'].toDate().month - now.month - 1} months/${snapshot.data['deliveryDate'].toDate().day - now.day + 30} days',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  10)
                                              .toDouble()),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!
                                          .data()!
                                          .containsKey('deliveryDate') &&
                                      (snapshot.data['deliveryDate'].toDate().month -
                                              now.month) >
                                          0 &&
                                      (snapshot.data['deliveryDate'].toDate().day -
                                              now.day) ==
                                          0) {
                                    return Text(
                                      '${snapshot.data['deliveryDate'].toDate().month - now.month} months/${snapshot.data['deliveryDate'].toDate().day - now.day} days',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  10)
                                              .toDouble()),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data!
                                          .data()!
                                          .containsKey('deliveryDate') &&
                                      (snapshot.data['deliveryDate'].toDate().month -
                                              now.month) ==
                                          0 &&
                                      (snapshot.data['deliveryDate'].toDate().day - now.day) > 0) {
                                    return Text(
                                      '${snapshot.data['deliveryDate'].toDate().month - now.month} months/${snapshot.data['deliveryDate'].toDate().day - now.day} days',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w700,
                                          fontSize: ((MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width) *
                                                  10)
                                              .toDouble()),
                                    );
                                  } else {
                                    return Text(
                                      '00/00',
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
                                    );
                                  }
                                })
                          ],
                        ),
                        Material(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(((MediaQuery.of(context)
                                              .size
                                              .height /
                                          MediaQuery.of(context).size.width) *
                                      8)
                                  .toDouble()),
                              child: Icon(Icons.calendar_today,
                                  color: Colors.white,
                                  size: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          15)
                                      .toDouble()),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () async {
                    final DocumentReference<Map<String, dynamic>>
                        documentReference = FirebaseFirestore.instance
                            .doc('Users/${loggedInUser!.displayName}');

                    try {
                      // Fetch the data from a document
                      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
                          await documentReference.get();
                      if (documentSnapshot.exists) {
                        var data =
                            documentSnapshot.data(); // Access the document data
                        if (data!.containsKey('deliveryDate')) {
                          return;
                        } else {
                          showInSnackBar(
                              'Please set Expected Delivery Date',
                              Colors.blueAccent,
                              context,
                              _scaffoldKey.currentContext!);
                        }
                      }
                    } catch (error) {
                      // Handle any potential errors
                      print('Error fetching data: $error');
                    }
                  },
                ),
                buildTile(
                  Padding(
                    padding: EdgeInsets.all(
                        ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12)
                            .toDouble()),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Material(
                            color: Colors.teal,
                            shape: const CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(((MediaQuery.of(context)
                                              .size
                                              .height /
                                          MediaQuery.of(context).size.width) *
                                      8)
                                  .toDouble()),
                              child: Icon(Icons.fastfood,
                                  color: Colors.white,
                                  size: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          15)
                                      .toDouble()),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          8)
                                      .toDouble())),
                          Text('Diet Chart',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      ((MediaQuery.of(context).size.height /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              10)
                                          .toDouble())),
                          Text('Seasonal || \nNon-Seasonal',
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize:
                                      ((MediaQuery.of(context).size.height /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              6)
                                          .toDouble())),
                        ]),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.grey,
                        elevation: 14,
                        title: const Text("App Info"),
                        content: const Text(
                          "This feature is unavailable in "
                          "the beta version.",
                          textAlign: TextAlign.justify,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Ok');
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );

                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => const dietPage(),
                    //   ),
                    // );
                  },
                ),
                buildTile(
                  Padding(
                    padding: EdgeInsets.all(
                        ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12)
                            .toDouble()),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Material(
                              color: Colors.amber,
                              shape: const CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(((MediaQuery.of(context)
                                                .size
                                                .height /
                                            MediaQuery.of(context).size.width) *
                                        8)
                                    .toDouble()),
                                child: Icon(Icons.notifications,
                                    color: Colors.white,
                                    size: ((MediaQuery.of(context).size.height /
                                                MediaQuery.of(context)
                                                    .size
                                                    .width) *
                                            15)
                                        .toDouble()),
                              )),
                          Padding(
                              padding: EdgeInsets.only(
                                  bottom: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          8)
                                      .toDouble())),
                          Text('Reminders',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      ((MediaQuery.of(context).size.height /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              10)
                                          .toDouble())),
                          Text('Vaccinations || \nAppointments',
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize:
                                      ((MediaQuery.of(context).size.height /
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width) *
                                              6)
                                          .toDouble())),
                        ]),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.grey,
                        elevation: 14,
                        title: const Text("App Info"),
                        content: const Text(
                          "This feature is unavailable in "
                          "the beta version.",
                          textAlign: TextAlign.justify,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Ok');
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );

                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => RemindersPage(),
                    //   ),
                    // );
                  },
                ),
                buildTile(
                  Padding(
                      padding: EdgeInsets.all(
                          ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  12)
                              .toDouble()),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Counseling & Exercise',
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: ((MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                12)
                                            .toDouble()),
                                  ),
                                  Row(
                                    children: [
                                      Text('My-Playlist',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w700,
                                              fontSize: ((MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width) *
                                                      10)
                                                  .toDouble())),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: ((MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width) *
                                                    6)
                                                .toDouble()),
                                        child: DropdownButton(
                                            isDense: true,
                                            value: actualDropdown,
                                            onChanged: (String? value) {
                                              setState(() {
                                                actualDropdown = value!;
                                                actualChart =
                                                    chartDropdownItems.indexOf(
                                                        value); // Refresh the chart
                                              });
                                            },
                                            items: chartDropdownItems
                                                .map((String title) {
                                              return DropdownMenuItem(
                                                value: title,
                                                child: Text(title,
                                                    style: TextStyle(
                                                        color: Colors.blue,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: ((MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width) *
                                                                7)
                                                            .toDouble())),
                                              );
                                            }).toList()),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(
                                ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        5.5)
                                    .toDouble()),
                            child: Icon(Icons.library_music,
                                color: Colors.pink,
                                size: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        45)
                                    .toDouble()),
                          ),
                        ],
                      )),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistPage(),
                      ),
                    );
                  },
                ),
                // _buildTile(
                //   Padding(
                //     padding: const EdgeInsets.all(24.0),
                //     child: Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: <Widget>[
                //           Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             crossAxisAlignment: CrossAxisAlignment.start,
                //             children: const <Widget>[
                //               Text('Community/Forum',
                //                   style: TextStyle(color: Colors.redAccent)),
                //               Text('Tap to Read',
                //                   style: TextStyle(
                //                       color: Colors.black,
                //                       fontWeight: FontWeight.w700,
                //                       fontSize: 30.0))
                //             ],
                //           ),
                //           Material(
                //             color: Colors.red,
                //             borderRadius: BorderRadius.circular(24.0),
                //             child: const Center(
                //               child: Padding(
                //                 padding: EdgeInsets.all(16.0),
                //                 child: Icon(Icons.chat_bubble,
                //                     color: Colors.white, size: 30.0),
                //               ),
                //             ),
                //           )
                //         ]),
                //   ),
                //   onTap: () => Navigator.of(context)
                //       .push(MaterialPageRoute(builder: (_) => ShopItemsPage())),
                // ),
                buildTile(
                  Padding(
                    padding: EdgeInsets.all(
                        ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12)
                            .toDouble()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Hospitals Nearby',
                                style: TextStyle(
                                    color: Colors.pinkAccent,
                                    fontSize:
                                        ((MediaQuery.of(context).size.height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                11)
                                            .toDouble())),
                            Text('Maps',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        ((MediaQuery.of(context).size.height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                12)
                                            .toDouble()))
                          ],
                        ),
                        Material(
                          color: Colors.cyan,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(((MediaQuery.of(context)
                                              .size
                                              .height /
                                          MediaQuery.of(context).size.width) *
                                      8)
                                  .toDouble()),
                              child: Icon(Icons.location_searching,
                                  color: Colors.white,
                                  size: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          18)
                                      .toDouble()),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.grey,
                        elevation: 14,
                        title: const Text("App Info"),
                        content: const Text(
                          "This feature is unavailable in "
                          "the beta version.",
                          textAlign: TextAlign.justify,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Ok');
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (_) => MapPage(),
                    //   ),
                    // );
                  },
                ),
                buildTile(
                  Padding(
                    padding: EdgeInsets.all(
                        ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12)
                            .toDouble()),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('App Info',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        ((MediaQuery.of(context).size.height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                15)
                                            .toDouble()))
                          ],
                        ),
                        Material(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(24.0),
                          child: Padding(
                            padding: EdgeInsets.all(
                                ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        8)
                                    .toDouble()),
                            child: Center(
                              child: Icon(Icons.info_sharp,
                                  color: Colors.white,
                                  size: ((MediaQuery.of(context).size.height /
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) *
                                          18)
                                      .toDouble()),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.grey,
                        elevation: 14,
                        title: const Text("App Info"),
                        content: const Text(
                          "This is a research app made in collaboration of FMC "
                          "with SMME, NUST. Developed in Aerial Robotics Lab.",
                          textAlign: TextAlign.justify,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Ok');
                            },
                            child: const Text('Ok'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

Widget buildTile(Widget child, {required Function() onTap}) {
  return Material(
    elevation: 14.0,
    borderRadius: BorderRadius.circular(12.0),
    shadowColor: const Color(0x802196F3),
    child: InkWell(
        // Do onTap() if it isn't null, otherwise do print()
        onTap: onTap != null
            ? () => onTap()
            : () {
                print('Not set yet');
              },
        child: child),
  );
}

// class CustomDialog extends StatelessWidget {
//   final String message;
//
//   const CustomDialog({Key? key, required this.message}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               message,
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog box
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
