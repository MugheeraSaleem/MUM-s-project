import 'package:flutter/material.dart';
import 'package:mum_s/pages/dashboard.dart';
import 'package:mum_s/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mum_s/pages/playlist_page.dart';
import 'package:mum_s/pages/profile_page.dart';
import 'package:mum_s/utils/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:mum_s/pages/exercises_page.dart';
import 'package:mum_s/pages/counseling_page.dart';
import 'package:mum_s/pages/media_page.dart';
import 'package:mum_s/pages/forgot_password_page.dart';
import 'package:mum_s/pages/forum.dart';
import 'package:mum_s/pages/map.dart';
import 'package:mum_s/pages/post.dart';
import 'package:mum_s/pages/reminders.dart';
import 'package:mum_s/utils/messaging_api.dart';
import 'package:localization/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAPi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        debugShowMaterialGrid: false,
        title: "MUM's",
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
          '/Dashboard': (context) => DashboardPage(),
          '/Profile': (context) => ProfilePage(),
          '/Playlist': (context) => PlaylistPage(),
          '/Exercises': (context) => const ExercisesPage(),
          '/Counseling': (context) => const CounselingPage(),
          '/Media': (context) => const MediaPage(),
          '/Forgot': (context) => const ForgotPasswordPage(),
          '/Forum': (context) => ItemReviewsPage(),
          '/Map': (context) => MapPage(),
          '/Music': (context) => const MediaPage(),
          '/Post': (context) => ShopItemsPage(),
          '/Reminders': (context) => RemindersPage(),
          // '/Video': (context) => VideoScreen(
          //     id: id, playlist: playlist, videoTitle: videoTitle, index: index)
        },
      ),
    );
  }
}

// I/flutter ( 8093): this is the device width 392.72727272727275
// I/flutter ( 8093): this is the device height 781.0909090909091
// this is the device pixelratio is 2.75

//todo: notify users when they haven't watched their weekly video.

//optional TODOs.

//todo: add location service and nearest hospital functionality using google maps.
//todo: add reminder functionality.
//todo: add messaging between patient and doctor.
//todo: make diet chart.
