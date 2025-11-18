import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// Utility function for showing success toast
void showSuccessToast({required String msg}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: Colors.green, // Success color
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

// Utility function for showing error toast
void showErrorToast({required String msg}) {
  
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 5,
    backgroundColor: Colors.red, // Error color
    textColor: Colors.white,
    fontSize: 16.0,
  );
  
}
