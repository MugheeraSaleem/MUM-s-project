import 'package:flutter/material.dart';

void showInSnackBar(String value, Color color, var context, var key) {
  FocusScope.of(context).requestFocus(
    FocusNode(),
  );
  // _scaffoldKey.currentState!.removeCurrentSnackBar();

  final scaffoldMessenger = ScaffoldMessenger.of(key);
  scaffoldMessenger.removeCurrentSnackBar();

  // _scaffoldKey.currentState?.showSnackBar(
  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ),
  );
}
