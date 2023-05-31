import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart'
    show InternetConnectionChecker;
import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart' show AppSettings;

class ConnectivityClass {
  bool isonline = false;
  late Function setStateandler;

  late StreamSubscription subscription;
  bool isDeviceConnected = false;
  bool isAlertSet = false;

  // method for checking stream of internet.
  void getConnectivity(context) {
    subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) async {
        isDeviceConnected = await InternetConnectionChecker().hasConnection;
        if (!isDeviceConnected && isAlertSet == false) {
          showAlert(context);
        }
      },
    );
  }

  //method for returning status to be used in ternary operators.
  Future<bool> checkInternet(context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      //print('connected'); // I am connected to a network.
      isonline = true;
    } else if (connectivityResult == ConnectivityResult.none &&
        isAlertSet == false) {
      // print('not connected'); // Not connected.
      isonline = false;
      showAlert(context);
    }
    return isonline;
  }

  // method to show the internet_not_connected alert.
  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Internet not detected. Please activate it."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, 'OK');
              AppSettings.openWIFISettings();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
