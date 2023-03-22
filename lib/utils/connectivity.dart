import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

bool isonline = false;

Future<bool> checkconnection() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile ||
      connectivityResult == ConnectivityResult.wifi) {
    //print('connected'); // I am connected to a mobile network.
    isonline = true;
  } else if (connectivityResult == ConnectivityResult.none) {
    // print('not connected'); // Not connected.
    isonline = false;
  }
  return isonline;
}
