import 'package:flutter/material.dart';

class SocdocAuthProvider extends ChangeNotifier {
  String userID = "";
  String userToken = "";

  void updateUser(String id, String token) {
    userID = id;
    userToken = token;
    notifyListeners();
  }
}