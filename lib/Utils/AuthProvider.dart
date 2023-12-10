import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String userID = "";
  String userToken = "";

  void updateUser(String id, String token) {
    userID = id;
    userToken = token;
  }
}