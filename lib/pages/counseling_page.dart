import 'package:mum_s/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:mum_s/style/constants.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:mum_s/utils/apiKey.dart';
import 'package:mum_s/classes/video.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mum_s/pages/video_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late User? loggedInUser;
var usersCollection = FirebaseFirestore.instance.collection('Users');

ConnectivityClass c_class = ConnectivityClass();
final _auth = FirebaseAuth.instance;
const int maxResults = 5; // Maximum number of results per page

class CounselingPage extends StatefulWidget {
  const CounselingPage({Key? key}) : super(key: key);

  @override
  State<CounselingPage> createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  bool _loading = true;
  List<Video> videos = [];
  String? nextPageToken;
  double _previousScrollPosition = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    c_class.getConnectivity(context);
    c_class.checkInternet(context);
    // This function is printing the users name and its email
    loggedInUser = getCurrentUser();
    fetchPlaylistVideos();
    scrollController.addListener(scrollListener);
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      fetchMoreVideos();
    }
  }

  Future<void> fetchPlaylistVideos() async {
    String apiUrl =
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=$maxResults&playlistId=$psychoEducationPlaylistId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final videosData = jsonData['items'];

        List<Video> fetchedVideos = [];

        for (var video in videosData) {
          final snippet = video['snippet'];
          final id = snippet['resourceId']['videoId'];
          final title = snippet['title'];
          final thumbnailUrl = snippet['thumbnails']['medium']['url'];
          final channelName = snippet['channelTitle'];

          fetchedVideos.add(Video(
            id: id,
            title: title,
            thumbnailUrl: thumbnailUrl,
            channelName: channelName,
          ));
        }

        setState(() {
          videos = fetchedVideos;
          _loading = false;
        });
        nextPageToken = jsonData['nextPageToken'];
      } else {
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> fetchMoreVideos() async {
    if (_loading || nextPageToken == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    String apiUrl =
        'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=$maxResults&playlistId=$psychoEducationPlaylistId&key=$apiKey';

    if (nextPageToken != null) {
      apiUrl += '&pageToken=$nextPageToken';
    }

    _previousScrollPosition = scrollController.position.pixels;

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final videosData = jsonData['items'];

        List<Video> fetchedVideos = [];

        for (var video in videosData) {
          final snippet = video['snippet'];
          final id = snippet['resourceId']['videoId'];
          final title = snippet['title'];
          final thumbnailUrl = snippet['thumbnails']['high']['url'];
          final channelName = snippet['channelTitle'];

          fetchedVideos.add(Video(
            id: id,
            title: title,
            thumbnailUrl: thumbnailUrl,
            channelName: channelName,
          ));
        }

        setState(() {
          videos.addAll(fetchedVideos);
          nextPageToken = jsonData['nextPageToken'];
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(_previousScrollPosition);
          }
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
      appBar: AppBar(
        elevation: 2.0,
        backgroundColor: kAppBarColor,
        title: Center(
          child: Text(
            'My Counseling',
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
      body: Container(
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
        child: ModalProgressHUD(
          progressIndicator: LoadingAnimationWidget.beat(
            color: Colors.pinkAccent,
            size: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    50)
                .toDouble(),
          ),
          dismissible: true,
          inAsyncCall: _loading,
          child: ListView.separated(
            separatorBuilder: (context, index) {
              return SizedBox(
                  height: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          3)
                      .toDouble()); // Replace with your desired spacing
            },
            controller: scrollController,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              if (index < videos.length) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoScreen(
                          id: video.id,
                          playlist: 'Counseling',
                          videoTitle: video.title,
                          index: index + 1,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                4)
                            .toDouble(),
                        right: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                4)
                            .toDouble(),
                        top: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                2)
                            .toDouble(),
                        bottom: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                2)
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(28),
                                topRight: Radius.circular(28),
                              ),
                              child: Image.network(
                                video.thumbnailUrl,
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: ((MediaQuery.of(context).size.height /
                                          MediaQuery.of(context).size.width) *
                                      2.5)
                                  .toDouble(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                right: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                bottom: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        2.5)
                                    .toDouble(),
                              ),
                              child: Text(
                                '${index + 1} || ${video.title}',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize:
                                        ((MediaQuery.of(context).size.height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                8)
                                            .toDouble(),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Poppins"),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                right: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                bottom: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                              ),
                              child: Text(
                                video.channelName,
                                style: TextStyle(
                                    fontSize:
                                        ((MediaQuery.of(context).size.height /
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) *
                                                7)
                                            .toDouble(),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins"),
                                textAlign: TextAlign.justify,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
