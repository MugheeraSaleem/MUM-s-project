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

  VideoScreen({required this.id});

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

  // static final List<String> videoQualities = [
  //   '360p',
  //   '480p',
  //   '720p',
  //   '1080p',
  // ];
  // String _selectedQuality = videoQualities[0];
  // int actualQuality = 0;

  @override
  void initState() {
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
        // topActions: [
        //   DropdownButton(
        //       isDense: true,
        //       value: _selectedQuality,
        //       onChanged: (String? value) {
        //         setState(() {
        //           _selectedQuality = value!;
        //           actualQuality =
        //               videoQualities.indexOf(value); // Refresh the chart
        //         });
        //         _changeVideoQuality(actualQuality);
        //       },
        //       items: videoQualities.map((String title) {
        //         return DropdownMenuItem(
        //           value: title,
        //           child: Text(title,
        //               style: const TextStyle(
        //                   color: Colors.blue,
        //                   fontWeight: FontWeight.w400,
        //                   fontSize: 14.0)),
        //         );
        //       }).toList())
        // ],
        progressColors: const ProgressBarColors(
          playedColor: Colors.purple, // Customize the played color
          handleColor: Colors.purpleAccent, // Customize the handle color
          bufferedColor: Colors.grey, // Customize the buffered color
        ),
        onEnded: (data) {
          print('here is what will get printed' + data.toString());
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
