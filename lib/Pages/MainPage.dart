import 'package:flutter/material.dart';

import 'package:socdoc_flutter/Pages/MainSubPages/HomePage.dart';
import 'package:socdoc_flutter/Pages/MainSubPages/SettingPage.dart';
import 'package:socdoc_flutter/Widgets/SocdocBottomNav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final _pageList = [
    HomePage(), SettingPage(),
  ];
  int pageIdx = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pageList[pageIdx - 1],
      ),
      bottomNavigationBar: const SafeArea(child: SocdocBottomNav())
    );
  }
}