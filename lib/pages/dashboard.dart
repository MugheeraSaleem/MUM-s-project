import 'package:mum_s/pages/map.dart';
import 'package:mum_s/pages/music.dart';
import 'package:mum_s/pages/reminders.dart';
import 'package:mum_s/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/style/theme.dart' as Theme;

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
  late ScrollController dashboardController;
  late var loggedInUser;

  @override
  void initState() {
    dashboardController = ScrollController();
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
            height: 65,
            width: 65,
            child: FloatingActionButton(
              backgroundColor: Colors.red,
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
                    builder: (context) => LoginPage(),
                  ),
                );
                showInSnackBar('Logged out Successfully', Colors.green, context,
                    _scaffoldKey.currentContext!);
              },
            ),
          ),
        ),
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2.0,
          backgroundColor: const Color(0xFF490648),
          title: const Center(
            child: Text(
              'Dashboard',
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
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      "My Profile",
                      style: TextStyle(
                        color: Colors.pink,
                      ),
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
        body: Container(
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
            controller: dashboardController,
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            staggeredTiles: const [
              StaggeredTile.extent(2, 110.0),
              StaggeredTile.extent(1, 180.0),
              StaggeredTile.extent(1, 180.0),
              StaggeredTile.extent(2, 220.0),
              StaggeredTile.extent(2, 110.0),
              StaggeredTile.extent(2, 110.0),
            ],
            children: <Widget>[
              _buildTile(
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Months and Days left',
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 15),
                          ),
                          Text('05/15',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 34.0))
                        ],
                      ),
                      Material(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(24.0),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.calendar_today,
                                color: Colors.white, size: 30.0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {},
              ),
              _buildTile(
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Material(
                            color: Colors.teal,
                            shape: CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.fastfood,
                                  color: Colors.white, size: 30.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 16.0)),
                        Text('Diet Chart',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 24.0)),
                        Text('Seasonal, Non-Seasonal',
                            style: TextStyle(
                                color: Colors.black45, fontSize: 10.0)),
                      ]),
                ),
                onTap: () {},
              ),
              _buildTile(
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Material(
                            color: Colors.amber,
                            shape: CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.notifications,
                                  color: Colors.white, size: 30.0),
                            )),
                        Padding(padding: EdgeInsets.only(bottom: 16.0)),
                        Text('Reminders',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 24.0)),
                        Text('vaccinations, Appointments',
                            style: TextStyle(
                                color: Colors.black45, fontSize: 11.0)),
                      ]),
                ),
                onTap: () {
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) => RemindersPage(),
                  //   ),
                  // );
                },
              ),
              _buildTile(
                Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Counseling & Exercise',
                                  style: TextStyle(
                                      color: Colors.pink, fontSize: 22.0),
                                ),
                                Text('My-Playlist',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20.0)),
                              ],
                            ),
                            DropdownButton(
                                isDense: true,
                                value: actualDropdown,
                                onChanged: (String? value) {
                                  setState(() {
                                    actualDropdown = value!;
                                    actualChart = chartDropdownItems
                                        .indexOf(value); // Refresh the chart
                                  });
                                },
                                items: chartDropdownItems.map((String title) {
                                  return DropdownMenuItem(
                                    value: title,
                                    child: Text(title,
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.0)),
                                  );
                                }).toList())
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.all(11.0),
                          child: Icon(Icons.library_music,
                              color: Colors.pink, size: 99.0),
                        ),
                      ],
                    )),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MusicHome(),
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
              _buildTile(
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Hospitals Nearby',
                              style: TextStyle(color: Colors.pinkAccent)),
                          Text('Maps',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30.0))
                        ],
                      ),
                      Material(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(24.0),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(Icons.location_searching,
                                color: Colors.white, size: 30.0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildTile(Widget child, {required Function() onTap}) {
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
            child: child));
  }
}
