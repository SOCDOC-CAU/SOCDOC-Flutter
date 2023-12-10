import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:socdoc_flutter/Pages/LoginPage.dart';
import 'package:socdoc_flutter/Pages/MainPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const SocdocApp());
}

class SocdocApp extends StatefulWidget {
  const SocdocApp({super.key});

  @override
  State<StatefulWidget> createState() => SocdocAppState();
}

class SocdocAppState extends State<SocdocApp> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "SOCDOC",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true
      ),
      home: isLoggedIn ? const MainPage() : const LoginPage(),
    );
  }
}