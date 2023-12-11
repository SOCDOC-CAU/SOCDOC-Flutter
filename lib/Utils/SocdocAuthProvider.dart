import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SocdocAuthProvider extends ChangeNotifier {
  String userID = "";
  String userToken = "";

  void updateUser() async {
    userID = FirebaseAuth.instance.currentUser!.uid;
    userToken = (await FirebaseAuth.instance.currentUser!.getIdToken())!;
    notifyListeners();
  }
}