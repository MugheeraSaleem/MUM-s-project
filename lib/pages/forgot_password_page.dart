import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mum_s/utils/TextEntryWidget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'
    show FontAwesomeIcons;
import 'package:mum_s/style/theme.dart' as Theme;
import 'package:draggable_fab/draggable_fab.dart';
import 'package:mum_s/utils/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mum_s/utils/snack_bar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode myFocusNodeEmailForgotPassword = FocusNode();
  final forgotPasswordEmailController = TextEditingController();
  ConnectivityClass c_class = ConnectivityClass();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    c_class.getConnectivity(context);
    c_class.checkInternet(context);
    super.initState();
  }

  @override
  void dispose() {
    c_class.subscription.cancel();
    myFocusNodeEmailForgotPassword.dispose();
    forgotPasswordEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: DraggableFab(
        child: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            backgroundColor: Colors.red,
            child: const Icon(
              size: 35,
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF490648),
        title: const Center(
          child: Text(
            'Forgot Password Page',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 30.0),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
            children: [
              const SizedBox(
                height: 200,
              ),
              const Text(
                'Receive an email to reset \n         your password',
                style: TextStyle(
                  fontFamily: "WorkSansBold",
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    8.0,
                  ),
                ),
                child: SizedBox(
                  width: 300,
                  height: 80,
                  child: TextEntryWidget(
                      hidetext: false,
                      simple_icon: const Icon(
                        FontAwesomeIcons.envelope,
                        color: Colors.black,
                        size: 22.0,
                      ),
                      trailing_icon: null,
                      displaytext: "Email Address",
                      myFocusNode: myFocusNodeEmailForgotPassword,
                      controller: forgotPasswordEmailController),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(5.0),
                  ),
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
                    tileMode: TileMode.clamp,
                  ),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Theme.Colors.loginGradientEnd,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: const Text(
                    "     RESET \n PASSWORD",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                        fontFamily: "WorkSansBold"),
                  ),
                  onPressed: () async {
                    if (forgotPasswordEmailController.text.isEmpty) {
                      showInSnackBar(
                        'Please provide all the information',
                        Colors.red,
                        context,
                        _scaffoldKey.currentContext!,
                      );
                    } else {
                      final bool isValid = EmailValidator.validate(
                          forgotPasswordEmailController.text);
                      if (isValid == false) {
                        showInSnackBar(
                          'Please provide a valid email',
                          Colors.red,
                          context,
                          _scaffoldKey.currentContext!,
                        );
                      } else {
                        await _auth.sendPasswordResetEmail(
                          email: forgotPasswordEmailController.text.trim(),
                        );
                        showInSnackBar(
                            'Check your valid email for password rest email',
                            Colors.tealAccent,
                            context,
                            _scaffoldKey);
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
