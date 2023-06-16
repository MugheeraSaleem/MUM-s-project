import 'package:flutter/material.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:mum_s/style/constants.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:draggable_fab/draggable_fab.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

late User? loggedInUser;
var usersCollection = FirebaseFirestore.instance.collection('Users');

ConnectivityClass c_class = ConnectivityClass();
final _auth = FirebaseAuth.instance;

class VideoScreen extends StatefulWidget {
  final String id;
  final String playlist;
  final String videoTitle;
  final int index;

  VideoScreen({
    required this.id,
    required this.playlist,
    required this.videoTitle,
    required this.index,
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late YoutubePlayerController _videoController;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late PlayerState _playerState;
  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  @override
  void initState() {
    loggedInUser = getCurrentUser();
    super.initState();
    _videoController = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
        controlsVisibleAtStart: true,
        mute: _muted,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_videoController.value.isFullScreen) {
      setState(() {
        _playerState = _videoController.value.playerState;
        _videoMetaData = _videoController.metadata;
      });
    }
  }

  Future<void> storeVideoProgress(index, videoTitle) async {
    try {
// Get the reference to the Firestore document
      DocumentReference docRef = usersCollection.doc(loggedInUser!.displayName);

      // Retrieve the existing map from Firestore
      DocumentSnapshot docSnapshot = await docRef.get();
      Map<String, dynamic>? alreadyWatchedVideos = (docSnapshot.data()
          as Map<String, dynamic>)['${widget.playlist} videos watched'];

      if (alreadyWatchedVideos != null) {
        alreadyWatchedVideos['$index || $videoTitle'] = 'yes';
        await docRef.set(
            {'${widget.playlist} videos watched': alreadyWatchedVideos},
            SetOptions(mergeFields: ['${widget.playlist} videos watched']));
      } else {
        Map<String, dynamic> watchedVideo = {'$index || $videoTitle': 'yes'};

        // Store the video progress in Firestore
        await usersCollection.doc(loggedInUser!.displayName).set({
          '${widget.playlist} videos watched': watchedVideo,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error storing video progress: $e');
    }
  }

  @override
  void deactivate() {
    _videoController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _videoController.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        onReady: () async {
          await usersCollection.doc(loggedInUser!.displayName).set({
            '${widget.playlist} last watched video': widget.index,
          }, SetOptions(merge: true));
        },
        progressColors: const ProgressBarColors(
          playedColor: Colors.purple, // Customize the played color
          handleColor: Colors.purpleAccent, // Customize the handle color
          bufferedColor: Colors.grey, // Customize the buffered color
        ),
        onEnded: (data) {
          storeVideoProgress(widget.index, widget.videoTitle);
          Navigator.pop(context);
        },
        controller: _videoController,
        showVideoProgressIndicator: true,
      ),
      builder: (context, player) => Scaffold(
        backgroundColor: Colors.black,
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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SingleChildScrollView(
              child: player,
            ),
          ],
        ),
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
