// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:mum_s/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:mum_s/utils/bubble_indication_painter.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mum_s/utils/TextEntryWidget.dart';
import 'package:mum_s/utils/user_actions.dart';
import 'package:mum_s/utils/google_sign_in.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:mum_s/pages/forgot_password_page.dart';
import 'package:mum_s/style/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

var usersCollection = FirebaseFirestore.instance.collection('Users');
late User? user;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();
  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController =
      TextEditingController();

  // get hold of the value of the controller using my_controller.text

  final PageController _pageController = PageController();
  final ScrollController loginPageController = ScrollController();

  ConnectivityClass c_class = ConnectivityClass();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;
  bool _loading = false;

  Color left = Colors.black;
  Color right = Colors.white;

  Future<void> checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId != null) {
      // Navigate to the HomeScreen or any other authenticated screen
      Navigator.pushReplacementNamed(context, '/Dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        progressIndicator: LoadingAnimationWidget.beat(
          color: Colors.pinkAccent,
          size: ((MediaQuery.of(context).size.height /
                      MediaQuery.of(context).size.width) *
                  50)
              .toDouble(),
        ),
        dismissible: true,
        inAsyncCall: _loading,
        child: SingleChildScrollView(
          controller: loginPageController,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              // overscroll.disallowIndicator();
              return true;
            },
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                37.5)
                            .toDouble()),
                    child: Image(
                      width: ((MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width) *
                              100)
                          .toDouble(),
                      height: ((MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width) *
                              75)
                          .toDouble(),
                      fit: BoxFit.fill,
                      image: AssetImage('assets/main_img.png'),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                10)
                            .toDouble()),
                    child: _buildMenuBar(context),
                  ),
                  Expanded(
                    flex: 2,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) {
                        if (i == 0) {
                          setState(() {
                            right = Colors.white;
                            left = Colors.black;
                          });
                        } else if (i == 1) {
                          setState(() {
                            right = Colors.black;
                            left = Colors.white;
                          });
                        }
                      },
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: _buildSignIn(context),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints.expand(),
                          child: _buildSignUp(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    checkLoggedInStatus();
    c_class.getConnectivity(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    c_class.checkInternet(context);
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    myFocusNodeEmailLogin.dispose();
    myFocusNodePasswordLogin.dispose();
    _pageController.dispose();
    loginPageController.dispose();
    c_class.subscription.cancel();
    super.dispose();
  }

  Widget _buildMenuBar(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: ((MediaQuery.of(context).size.height /
                    MediaQuery.of(context).size.width) *
                150)
            .toDouble(),
        height: ((MediaQuery.of(context).size.height /
                    MediaQuery.of(context).size.width) *
                25)
            .toDouble(),
        decoration: const BoxDecoration(
          color: Color(0x552B2B2B),
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        child: CustomPaint(
          painter: TabIndicationPainter(pageController: _pageController),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  // highlightColor: Colors.transparent,
                  onPressed: _onSignInButtonPress,
                  child: Text(
                    "Existing",
                    style: TextStyle(
                        color: left,
                        fontSize: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                8)
                            .toDouble(),
                        fontFamily: "WorkSansSemiBold"),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  // highlightColor: Colors.transparent,
                  onPressed: _onSignUpButtonPress,
                  child: Text(
                    "New",
                    style: TextStyle(
                        color: right,
                        fontSize: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                8)
                            .toDouble(),
                        fontFamily: "WorkSansSemiBold"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
          top: ((MediaQuery.of(context).size.height /
                      MediaQuery.of(context).size.width) *
                  11.5)
              .toDouble()),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ),
                ),
                child: SizedBox(
                  width: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          150)
                      .toDouble(),
                  height: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          95)
                      .toDouble(),
                  child: Column(
                    children: <Widget>[
                      TextEntryWidget(
                          hidetext: false,
                          simple_icon: const Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.black,
                          ),
                          trailing_icon: null,
                          displaytext: "Email Address",
                          myFocusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController),
                      Container(
                        width: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                125)
                            .toDouble(),
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      TextEntryWidget(
                        hidetext: _obscureTextLogin,
                        myFocusNode: myFocusNodePasswordLogin,
                        controller: loginPasswordController,
                        displaytext: "Password",
                        trailing_icon: GestureDetector(
                          onTap: _toggleLogin,
                          child: Icon(
                            _obscureTextLogin
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            size: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    7.5)
                                .toDouble(),
                            color: Colors.black,
                          ),
                        ),
                        simple_icon: const Icon(
                          FontAwesomeIcons.lock,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Hero(
                tag: 'yo',
                child: Container(
                  margin: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width) *
                              85)
                          .toDouble()),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: Theme.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientEnd,
                          Theme.Colors.loginGradientStart
                        ],
                        begin: FractionalOffset(0.2, 0.2),
                        end: FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Theme.Colors.loginGradientEnd,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  5)
                              .toDouble(),
                          horizontal: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  21)
                              .toDouble()),
                      child: Text(
                        "LOGIN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    12.5)
                                .toDouble(),
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () async {
                      Future<bool> networkStatus =
                          c_class.checkInternet(context);
                      if (loginEmailController.text.trim().isEmpty ||
                          loginPasswordController.text.trim().isEmpty) {
                        showInSnackBar('Please provide all the information',
                            Colors.red, context, _scaffoldKey.currentContext!);
                      }
                      try {
                        setState(() {
                          _loading = true;
                        });

                        user = await logIn(loginEmailController.text.trim(),
                            loginPasswordController.text.trim());

                        if (await networkStatus == true && user != null) {
                          showInSnackBar('Logged in Successfully', Colors.green,
                              context, _scaffoldKey.currentContext!);
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('user_id', user!.uid);
                          Navigator.push(
                            context,
                            prefix0.MaterialPageRoute(
                              builder: (context) => DashboardPage(),
                            ),
                          );
                          setState(() {
                            _loading = false;
                          });
                        }
                        setState(() {
                          _loading = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          _loading = false;
                        });
                        if (e.code == 'invalid-email') {
                          showInSnackBar(
                              'Please provide a valid email',
                              Colors.red,
                              context,
                              _scaffoldKey.currentContext!);
                        }
                        if (e.code == 'wrong-password') {
                          showInSnackBar(
                              'Please type the correct Password',
                              Colors.red,
                              context,
                              _scaffoldKey.currentContext!);
                        }
                        if (e.code == 'user-not-found') {
                          showInSnackBar(
                              'Please signup before logging in',
                              Colors.red,
                              context,
                              _scaffoldKey.currentContext!);
                        }
                      } catch (e) {
                        setState(() {
                          _loading = false;
                        });
                        showInSnackBar(
                            'Unexpected error occurred while logging in',
                            Colors.red,
                            context,
                            _scaffoldKey.currentContext!);
                        print('here is the exception causing trouble $e');
                      }
                    },
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
                top: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        5)
                    .toDouble()),
            child: TextButton(
              onPressed: () {
                print(
                    'this is the device width ${MediaQuery.of(context).size.width}');
                print(
                    'this is the device height ${MediaQuery.of(context).size.height}');
                print(
                    'this is the device pixelratio ${MediaQuery.of(context).devicePixelRatio}');

                Navigator.push(
                  context,
                  prefix0.MaterialPageRoute(
                    builder: (context) => const ForgotPasswordPage(),
                  ),
                );
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            8)
                        .toDouble(),
                    fontFamily: "WorkSansMedium"),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: ((MediaQuery.of(context).size.height /
                            MediaQuery.of(context).size.width) *
                        5)
                    .toDouble()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.white10,
                          Colors.white,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          50)
                      .toDouble(),
                  height: 1.0,
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
                          .toDouble()),
                  child: Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                8)
                            .toDouble(),
                        fontFamily: "WorkSansMedium"),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white10,
                        ],
                        begin: FractionalOffset(0.0, 0.0),
                        end: FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  width: ((MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width) *
                          50)
                      .toDouble(),
                  height: 1.0,
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  child: Container(
                    width: deviceSize.width / 1.8,
                    height: deviceSize.height / 16,
                    margin: EdgeInsets.only(
                        top: ((MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width) *
                                12.5)
                            .toDouble()),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: kAppBarColor,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            height: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    20)
                                .toDouble(),
                            width: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    20)
                                .toDouble(),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage('assets/google.png'),
                                  fit: BoxFit.cover),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            'Sign in with Google',
                            style: TextStyle(
                                fontSize: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        9)
                                    .toDouble(),
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () async {
                    Future<bool> networkStatus = c_class.checkInternet(context);
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);

                    try {
                      setState(() {
                        _loading = true;
                      });

                      showInSnackBar("Google button pressed", Colors.blue,
                          context, _scaffoldKey.currentContext!);

                      UserCredential googleUser = await provider.googleLogin();

                      user = googleUser.user;

                      if (await networkStatus == true && user != null) {
                        Map<String, dynamic> userData = {
                          'uid': user!.uid,
                          'displayName': user!.displayName,
                          'photoURL': user!.photoURL,
                          'email': user!.email,
                        };

                        await usersCollection
                            .doc(user!.displayName)
                            .set(userData, SetOptions(merge: true))
                            .then((_) => print('Success'))
                            .catchError((error) => print('Failed: $error'));

                        showInSnackBar('Logged in Successfully', Colors.green,
                            context, _scaffoldKey.currentContext!);

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString('user_id', user!.uid);

                        Navigator.push(
                          context,
                          prefix0.MaterialPageRoute(
                            builder: (context) => DashboardPage(),
                          ),
                        );
                        setState(() {
                          _loading = false;
                        });
                      }
                      setState(() {
                        _loading = false;
                      });
                    } catch (e) {
                      setState(() {
                        _loading = false;
                      });
                      print('here is the exception causing trouble $e');
                      showInSnackBar(
                          'Unexpected error occurred while logging in',
                          Colors.red,
                          context,
                          _scaffoldKey.currentContext!);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
            top: ((MediaQuery.of(context).size.height /
                        MediaQuery.of(context).size.width) *
                    11.5)
                .toDouble()),
        child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: <Widget>[
                Card(
                  elevation: 2.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SizedBox(
                    width: ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            150)
                        .toDouble(),
                    height: ((MediaQuery.of(context).size.height /
                                MediaQuery.of(context).size.width) *
                            180)
                        .toDouble(),
                    child: Column(
                      children: <Widget>[
                        TextEntryWidget(
                            myFocusNode: myFocusNodeName,
                            controller: signupNameController,
                            displaytext: "Name",
                            trailing_icon: null,
                            simple_icon: const Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hidetext: false),
                        Container(
                          width: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  125)
                              .toDouble(),
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        TextEntryWidget(
                          myFocusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          displaytext: "Email Address",
                          trailing_icon: null,
                          simple_icon: const Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.black,
                          ),
                          hidetext: false,
                        ),
                        Container(
                          width: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  125)
                              .toDouble(),
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        TextEntryWidget(
                            myFocusNode: myFocusNodePassword,
                            controller: signupPasswordController,
                            displaytext: "Password",
                            trailing_icon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _obscureTextSignup
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                color: Colors.black,
                              ),
                            ),
                            simple_icon: const Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hidetext: _obscureTextSignup),
                        Container(
                          width: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  125)
                              .toDouble(),
                          height: 1.0,
                          color: Colors.grey[400],
                        ),
                        TextEntryWidget(
                            myFocusNode: null,
                            controller: signupConfirmPasswordController,
                            displaytext: "Confirmation",
                            trailing_icon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _obscureTextSignupConfirm
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: ((MediaQuery.of(context).size.height /
                                            MediaQuery.of(context).size.width) *
                                        7.5)
                                    .toDouble(),
                                color: Colors.black,
                              ),
                            ),
                            simple_icon: const Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hidetext: _obscureTextSignupConfirm)
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      top: ((MediaQuery.of(context).size.height /
                                  MediaQuery.of(context).size.width) *
                              170)
                          .toDouble()),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Theme.Colors.loginGradientStart,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                      BoxShadow(
                        color: Theme.Colors.loginGradientEnd,
                        offset: Offset(1.0, 6.0),
                        blurRadius: 20.0,
                      ),
                    ],
                    gradient: LinearGradient(
                        colors: [
                          Theme.Colors.loginGradientEnd,
                          Theme.Colors.loginGradientStart
                        ],
                        begin: FractionalOffset(0.2, 0.2),
                        end: FractionalOffset(1.0, 1.0),
                        stops: [0.0, 1.0],
                        tileMode: TileMode.clamp),
                  ),
                  child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: Theme.Colors.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  5)
                              .toDouble(),
                          horizontal: ((MediaQuery.of(context).size.height /
                                      MediaQuery.of(context).size.width) *
                                  21)
                              .toDouble()),
                      child: Text(
                        "SIGN UP",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: ((MediaQuery.of(context).size.height /
                                        MediaQuery.of(context).size.width) *
                                    12.5)
                                .toDouble(),
                            fontFamily: "WorkSansBold"),
                      ),
                    ),
                    onPressed: () async {
                      c_class.checkInternet(context);
                      if (signupNameController.text.trim().isEmpty ||
                          signupEmailController.text.trim().isEmpty ||
                          signupPasswordController.text.trim().isEmpty ||
                          signupConfirmPasswordController.text.trim().isEmpty) {
                        showInSnackBar('Please provide all the information',
                            Colors.red, context, _scaffoldKey.currentContext!);
                      } else if (signupPasswordController.text.trim() !=
                          signupConfirmPasswordController.text.trim()) {
                        showInSnackBar('Passwords must match', Colors.red,
                            context, _scaffoldKey.currentContext!);
                      } else {
                        try {
                          setState(() {
                            _loading = true;
                          });

                          final User? newUser = await registerUser(
                              signupEmailController.text.trim(),
                              signupPasswordController.text.trim(),
                              signupNameController.text.trim());

                          Future<bool> networkStatus =
                              c_class.checkInternet(context);
                          if (await networkStatus == true && newUser != null) {
                            Map<String, dynamic> userData = {
                              'uid': newUser.uid,
                              'displayName': signupNameController.text.trim(),
                              'photoURL': newUser.photoURL,
                              'email': newUser.email,
                              // 'deliveryDate': DateTime.now(),
                              // 'age': null,
                              // 'weight': null,
                              // 'height': null
                            };

                            await usersCollection
                                .doc(signupNameController.text.trim())
                                .set(userData)
                                .then((_) => print('Success'))
                                .catchError((error) => print('Failed: $error'));

                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('user_id', newUser.uid);

                            showInSnackBar(
                                'User Created Successfully',
                                Colors.green,
                                context,
                                _scaffoldKey.currentContext!);
                            Navigator.push(
                              context,
                              prefix0.MaterialPageRoute(
                                builder: (context) => DashboardPage(),
                              ),
                            );
                            setState(() {
                              _loading = false;
                            });
                          }
                          // here
                        } on FirebaseAuthException catch (e) {
                          setState(() {
                            _loading = false;
                          });
                          if (e.code == 'invalid-email') {
                            showInSnackBar(
                                'Please provide a valid email',
                                Colors.red,
                                context,
                                _scaffoldKey.currentContext!);
                          }
                          if (e.code == 'weak-password') {
                            showInSnackBar(
                                'The password provided is too weak.',
                                Colors.red,
                                context,
                                _scaffoldKey.currentContext!);
                          } else if (e.code == 'email-already-in-use') {
                            showInSnackBar(
                                'An account already exists for this email.',
                                Colors.red,
                                context,
                                _scaffoldKey.currentContext!);
                          }
                        } catch (e) {
                          setState(() {
                            _loading = false;
                          });
                          showInSnackBar(
                              'Unexpected error occurred while signing up',
                              Colors.red,
                              context,
                              _scaffoldKey.currentContext!);
                          print(e);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 600), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}
