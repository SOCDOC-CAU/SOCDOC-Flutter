import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socdoc_flutter/Pages/MainSubPages/HomeShortcut.dart';
import 'package:socdoc_flutter/Utils/AuthUtil.dart';
import 'package:socdoc_flutter/Utils/HospitalTypes.dart';
import '../../Utils/Color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading_hospital = true;
  var FamousHospitalData;
  var UserLocationData;
  final edgeInsets = EdgeInsets.only(left: 16.0, top: 5.0);
  final detailHospitalStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  final titleHospital = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.SocdocBlue);
  final pagetitle = TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.bold);
  String address1='';
  String address2='';
  Widget circularProgress(){
    return Center(
      child: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Container(
              width: 100,
              height: 100,
              child: CircularProgressIndicator()
          )
      ),
    );
  }
  Future<void> userLocation() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/user?userId=${getUserID()}"))
        .then((value){
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        UserLocationData = jsonDecode(tmp)["data"];
        address1 = UserLocationData['address1'];
        address2 = UserLocationData['address2'];
        // print(value.body);
        // print("UserLocationData"+UserLocationData);

      });
    })
        .onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }
  Future<void> MainFamousHospitalInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/hospital/list?"
        "address1=${address1}&address2=${address2}&pageNum=1&sortType=0"))
        .then((value){
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        FamousHospitalData = jsonDecode(tmp)["data"];
        // print(value.body);
        // print(FamousHospitalData);
        // print(address1);
        // print(address2);
        isLoading_hospital = false;
      });
    })
        .onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }
  Widget MainFamousHospital(){
    if(isLoading_hospital){
      return circularProgress();
    }else if(FamousHospitalData != null){
      return ListView.builder(

          itemCount: FamousHospitalData.length,
          itemBuilder: (context, index) {
            var hospital =  FamousHospitalData[index];
            String hospitalName = hospital["name"];
            String hospitalAddress = hospital["address"];
            String hospitalRating = hospital["rating"].toString();
            return HospitalCard(hospitalName, hospitalAddress,hospitalRating);
          },
        );
        }
    else{
      return Text("데이터를 불러오는 중에 오류가 발생했습니다.");
    }
  }
  List<int> selectedTileIndices = [1,5,8,12];
  @override
  void initState() {
    super.initState();
    MainFamousHospitalInfo();
    userLocation();
    WidgetsBinding.instance.addObserver(
      _LifecycleObserver(resumeCallback: () async => loadSelectedIndices())
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSelectedIndices();
    });
  }

  Future<void> loadSelectedIndices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedIndices = prefs.getStringList('selectedIndices');

    if (storedIndices != null && storedIndices.length == 4 && mounted) {
      setState(() {
        selectedTileIndices = storedIndices.map((index) => int.parse(index)).toList();
      });
    }else if(mounted){
      setState(() {
        selectedTileIndices = [1,5,8,12];
      });
    }
  }
  Widget Location(){
    return Container(
      width: double.infinity,
      height: 100.0,
      decoration:  BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20.0,
            spreadRadius: -20.0,
            offset: Offset(0.0, 25.0),
          )
        ],
        color: AppColor.SocdocBlue,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
      ),
      child :
      Container(
        margin : const EdgeInsets.all(25),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color : Colors.white,
              size : 35.0,
            ),
            SizedBox(width: 10.0),
            Text('서울시 동작구',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.0,
                  fontWeight:
                  FontWeight.bold),),

          ],
        ),

      ),
    );
  }
  Widget SpecialtyCard(String specialty, int n){
    return Padding(
      padding: const EdgeInsets.only(top:10.0),
      child:
      Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Container(
              width: 70,
              height: 70,
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  child:
                  Image(
                    image: AssetImage('assets/hospital/${selectedTileIndices[n]}.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height:10.0),
          Text(specialty,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15.0, ),
          ),
        ],
      ),

    );
  }
  //우리 동네 병원 한 눈에 보기
  Widget NearbyHospital(){
    return Column(
      children: [
        Row(
          children: [
            Text('우리 동네 병원 한 눈에 보기', style: pagetitle),
            SizedBox(width: 5.0),
            GestureDetector(
              onTap:((){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeShortcut())).then((value) => loadSelectedIndices());
              }),

              child:Icon(
                Icons.
                settings,
                color : Colors.black,
                size : 30.0,
              ),
            ),
          ],
        ),
        SizedBox(width: 10.0,),
        Row(
          children: [
            Expanded(
                flex:1,
                child: SpecialtyCard(HospitalTypes[selectedTileIndices[0]].ko,0)),
            Expanded(
              flex:1,
              child: Padding(
                padding: const EdgeInsets.only(left:5.0),
                child: SpecialtyCard(HospitalTypes[selectedTileIndices[1]].ko ,1),
              ),
            ),
            Expanded(
              flex:1,
              child: Padding(
                padding: const EdgeInsets.only(left:5.0),
                child: SpecialtyCard(HospitalTypes[selectedTileIndices[2]].ko,2),
              ),
            ),
            Expanded(
              flex:1,
              child: Padding(
                padding: const EdgeInsets.only(left:5.0),
                child: SpecialtyCard(HospitalTypes[selectedTileIndices[3]].ko,3),
              ),
            ),
          ],
        ),
      ],
    );
  }
  //카드 안에 주소
  Widget HospitalAddress(String text) {
    return Row(
      children: [
        Padding(padding: edgeInsets, child: Icon(Icons.location_on)),
        Padding(padding: EdgeInsets.only(left: 10.0)),
        Text(text, style: detailHospitalStyle),
      ],
    );
  }
  //카드
  Widget HospitalCard(String text, String address, String rating) {
    return
      Padding(
        padding: const EdgeInsets.only(top : 20.0),
        child: SizedBox(
          height: 265, width: double.infinity,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 10.0,
            surfaceTintColor: Colors.transparent,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 12.0,right:12.0, top:12.0, bottom:2.0 ),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0), // 여기서 원하는 둥근 정도를 설정합니다.
                      child:  Image(
                        image: AssetImage('assets/images/hospital1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0,right: 20.0,),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(text, style: titleHospital),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top:5.0),
                            child: Icon(Icons.star_rounded, color: Colors.amberAccent),
                          ),
                          Text(rating),
                        ],
                      ),
                    ],
                  ),
                ),
                HospitalAddress(address),
              ],
            ),
          ),
        ),
      );
  }
  //우리 동네 인기병원
  Widget FamousHospital(){
    return Container(
      child:
      Padding(
        padding: const EdgeInsets.only(top:25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('우리 동네 인기 병원', style: pagetitle ),
            Container(
              margin: EdgeInsets.only(top: 5.0), // Text와 NearbyPharmacy 사이의 간격을 설정
              child: Column(
                children: [
                  MainFamousHospital(),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.black, // 시간 및 배터리 표시줄의 배경색
        statusBarIconBrightness: Brightness.light, // 시간 및 배터리 아이콘 색상
        systemNavigationBarColor: Colors.black, // 하단 네비게이션 바 배경색 (Android)
        systemNavigationBarIconBrightness: Brightness.light, // 하단 네비게이션 바 아이콘 색상 (Android)
      ),
    );




    return
      Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:
          Column(
            children: [
              Location(),
              Padding(
                  padding: EdgeInsets.only(top: 25.0, left:20.0,right:20.0),
                  child: Column(
                    children: [
                      NearbyHospital(),
                      FamousHospital(),

                      //FamousHospital(),
                    ],
                  )
              ),

            ],
          ),
        ),
      );
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final AsyncCallback? resumeCallback;

  _LifecycleObserver({
    this.resumeCallback
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch(state) {
      case AppLifecycleState.resumed:
        if(resumeCallback != null){
          await resumeCallback!();
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        break;
    }
  }
}