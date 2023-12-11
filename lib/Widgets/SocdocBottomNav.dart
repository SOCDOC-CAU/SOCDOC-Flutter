import 'package:flutter/material.dart';

import 'package:socdoc_flutter/Pages/MainPage.dart';
import 'package:socdoc_flutter/Pages/SearchPage.dart';

class SocdocBottomNav extends StatefulWidget {
  const SocdocBottomNav({super.key});

  @override
  State<StatefulWidget> createState() => SocdocBottomNavState();
}

class SocdocBottomNavState extends State<SocdocBottomNav> {
  MainPageState? mainPage;

  @override
  Widget build(BuildContext context) {
    mainPage = context.findAncestorStateOfType<MainPageState>()!;
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: (){openSearch();},
            child: Column(
              children: [
                IconButton(
                  onPressed: (){openSearch();},
                  icon: const Icon(Icons.search, size: 30.0)),
                const Text('Search',
                  style: TextStyle(fontSize: 15.0),
                )
              ],
            ),
          ),
          IconButton(
            onPressed: (){updateIdx(1);},
            icon: const Image(
                height: double.infinity,
                fit: BoxFit.fill,
                image: AssetImage('assets/socdoc_logo.png'))),
          InkWell(
            onTap: (){updateIdx(2);},
            child: Column(
              children: [
                IconButton(
                  onPressed: (){updateIdx(2);},
                  icon: const Icon(Icons.person, size: 30.0)),
                const Text('My Page',
                  style: TextStyle(fontSize: 15.0),
                )
              ],
            ),
          ),
        ]
      ),
    );
  }

  void openSearch(){
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => SearchPage()
      ));
  }

  void updateIdx(idx){
    mainPage!.setState((){
      mainPage!.pageIdx = idx;
    });
  }
}