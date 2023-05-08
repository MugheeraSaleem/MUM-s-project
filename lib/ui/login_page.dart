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
import 'package:mum_s/classes/user_actions.dart';
import 'package:mum_s/utils/snack_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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

  final db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  late String email;
  late String password;
  late String username;

  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  // get hold of the value of the controller using my_controller.text

  ConnectivityClass c_class = ConnectivityClass();

  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;
  bool _loading = false;

  TextEditingController signupEmailController = TextEditingController();
  TextEditingController signupNameController = TextEditingController();
  TextEditingController signupPasswordController = TextEditingController();
  TextEditingController signupConfirmPasswordController =
      TextEditingController();

  late PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        progressIndicator: LoadingAnimationWidget.beat(
          color: Colors.pinkAccent,
          size: 100,
        ),
        dismissible: true,
        inAsyncCall: _loading,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
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
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 75.0),
                    child: Image(
                      width: 250.0,
                      height: 191.0,
                      fit: BoxFit.fill,
                      image: AssetImage('assets/img/login_logo.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
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
    c_class.getConnectivity(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
    c_class.checkInternet(context);
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    _pageController.dispose();
    c_class.subscription.cancel();
    super.dispose();
  }

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: const BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
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
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
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
                      fontSize: 16.0,
                      fontFamily: "WorkSansSemiBold"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
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
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      TextEntryWidget(
                          hidetext: false,
                          simple_icon: const Icon(
                            FontAwesomeIcons.envelope,
                            color: Colors.black,
                            size: 22.0,
                          ),
                          trailing_icon: null,
                          displaytext: "Email Address",
                          myFocusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController),
                      Container(
                        width: 250.0,
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
                            size: 15.0,
                            color: Colors.black,
                          ),
                        ),
                        simple_icon: const Icon(
                          FontAwesomeIcons.lock,
                          size: 22.0,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 170.0),
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
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: "WorkSansBold"),
                    ),
                  ),
                  onPressed: () async {
                    Future<bool> networkStatus = c_class.checkInternet(context);
                    if (loginEmailController.text.isEmpty ||
                        loginPasswordController.text.isEmpty) {
                      showInSnackBar('Please provide all the information',
                          Colors.red, context, _scaffoldKey.currentContext!);
                    }
                    try {
                      setState(() {
                        _loading = true;
                      });

                      User user = await logIn(loginEmailController.text,
                          loginPasswordController.text);
                      if (await networkStatus == true && user != null) {
                        showInSnackBar('Logged in Successfully', Colors.green,
                            context, _scaffoldKey.currentContext!);
                        Navigator.push(
                          context,
                          prefix0.MaterialPageRoute(
                            builder: (context) => MainPage(),
                          ),
                        );
                        setState(() {
                          _loading = false;
                        });
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        _loading = false;
                      });
                      if (e.code == 'invalid-email') {
                        showInSnackBar('Please provide a valid email',
                            Colors.red, context, _scaffoldKey.currentContext!);
                      }
                      if (e.code == 'wrong-password') {
                        showInSnackBar('Please type the correct Password',
                            Colors.red, context, _scaffoldKey.currentContext!);
                      }
                      if (e.code == 'user-not-found') {
                        showInSnackBar('Please signup before logging in',
                            Colors.red, context, _scaffoldKey.currentContext!);
                      }
                    } catch (e) {
                      setState(() {
                        _loading = false;
                      });
                      showInSnackBar('Unexpected error occurred', Colors.red,
                          context, _scaffoldKey.currentContext!);
                      print(e);
                    }
                  },
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 16.0,
                    fontFamily: "WorkSansMedium"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
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
                  width: 100.0,
                  height: 1.0,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: Text(
                    "Or",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
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
                  width: 100.0,
                  height: 1.0,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 40.0),
                child: GestureDetector(
                  onTap: () {
                    showInSnackBar("Facebook button pressed", Colors.blue,
                        context, _scaffoldKey.currentContext!);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.facebookF,
                      color: Color(0xFF0084ff),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    showInSnackBar("Google button pressed", Colors.blue,
                        context, _scaffoldKey.currentContext!);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      FontAwesomeIcons.google,
                      color: Color(0xFF0084ff),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 23.0),
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
                  width: 300.0,
                  height: 360.0,
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
                        width: 250.0,
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
                        width: 250.0,
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
                              size: 15.0,
                              color: Colors.black,
                            ),
                          ),
                          simple_icon: const Icon(
                            FontAwesomeIcons.lock,
                            color: Colors.black,
                          ),
                          hidetext: _obscureTextSignup),
                      Container(
                        width: 250.0,
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
                              size: 15.0,
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
                margin: const EdgeInsets.only(top: 340.0),
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
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: "WorkSansBold"),
                    ),
                  ),
                  onPressed: () async {
                    c_class.checkInternet(context);
                    if (signupNameController.text.isEmpty ||
                        signupEmailController.text.isEmpty ||
                        signupPasswordController.text.isEmpty ||
                        signupConfirmPasswordController.text.isEmpty) {
                      showInSnackBar('Please provide all the information',
                          Colors.red, context, _scaffoldKey.currentContext!);
                    } else if (signupPasswordController.text !=
                        signupConfirmPasswordController.text) {
                      showInSnackBar('Passwords must match', Colors.red,
                          context, _scaffoldKey.currentContext!);
                    } else {
                      try {
                        setState(() {
                          _loading = true;
                        });

                        final newUser = await registerUser(
                            signupEmailController.text,
                            signupPasswordController.text,
                            signupNameController.text);

                        // print('////////////////// newuser with name is ' +
                        //     newUser.toString());

                        Future<bool> networkStatus =
                            c_class.checkInternet(context);
                        if (await networkStatus == true && newUser != null) {
                          showInSnackBar(
                              'User Created Successfully',
                              Colors.green,
                              context,
                              _scaffoldKey.currentContext!);
                          Navigator.push(
                            context,
                            prefix0.MaterialPageRoute(
                              builder: (context) => MainPage(),
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
                        showInSnackBar('Unexpected error occurred', Colors.red,
                            context, _scaffoldKey.currentContext!);
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
