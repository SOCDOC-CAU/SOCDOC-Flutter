import 'package:flutter/material.dart';
import 'package:socdoc_flutter/Utils/AuthUtil.dart';
import 'package:socdoc_flutter/main.dart';
import 'package:socdoc_flutter/Utils/Color.dart';
import 'package:socdoc_flutter/Pages/MainSubPages/SettingAddressPage.dart';
import 'dart:convert';
import "package:http/http.dart" as http;

class SettingPage extends StatefulWidget{
  const SettingPage({Key? key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String userName = "";
  String userAddress = "";
  var favoriteHospital = null;
  bool isLoading_userInfo = true;
  bool isLoading_favoriteHospital = true;

  @override
  void initState() {
    super.initState();
    userInfo();
    favoriteHospitalInfo();
  }

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

  Future<void> userInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/user?userId=${getUserID()}"))
        .then((value){
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        userName = jsonDecode(tmp)["data"]["userName"];
        userAddress = jsonDecode(tmp)["data"]["address1"] + ' '+ jsonDecode(tmp)["data"]["address2"];
        print(value.body);
        isLoading_userInfo = false;
      });
    }).onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }

  Future<void> favoriteHospitalInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/hospital/like?userId=${getUserID()}"))
        .then((value){
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        favoriteHospital = jsonDecode(tmp)["data"];
        print("********^^좋아요누른병원**");
        print(value.body);
        print(favoriteHospital);
        isLoading_favoriteHospital = false;
      });
    })
        .onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }

  Widget build(BuildContext context) {
    SocdocAppState socdocApp = context.findAncestorStateOfType<SocdocAppState>()!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserInfo(userName, userAddress, context),
            SizedBox(height: 20.0),
            MyPageList("즐겨찾기 병원 목록", Icons.favorite_border),
            FavoriteHospital(),
            SizedBox(height: 20.0),
            MyPageList("내 리뷰 보기", Icons.rate_review_outlined),
            MyReviewList(),
            BuildTextButton("로그아웃", () => _showLogoutDialog(socdocApp, context)),
            BuildTextButton("회원 탈퇴", () => _showDeleteUserDialog(socdocApp, context)),
          ],
        ),
      ),
    );
  }

  Widget UserInfo(String name, String address, BuildContext context) {
    if(isLoading_userInfo) return circularProgress();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(
            width: 75,
            height: 75,
            child: ClipOval(
              child: Image(
                image: AssetImage('assets/user.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 25.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(
                        fontSize: 30.0, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () {
                        _nickNameDialog(context);
                      },
                      icon: Icon(Icons.arrow_forward_ios_rounded,
                          color: Colors.black, size: 20.0),
                    ),
                  ],
                ),
                SizedBox(height: 3.0),
                Row(
                  children: [
                    Icon(Icons.home_work_outlined, color: Colors.grey,
                        size: 18.0),
                    SizedBox(width: 5.0),
                    Text(address,
                        style: TextStyle(fontSize: 15.0, color: Colors.grey)),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingAddressPage(),
                          ),
                        );
                      },
                      icon: Icon(
                          Icons.arrow_forward_ios_rounded, color: Colors.grey,
                          size: 15.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _nickNameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('닉네임을 입력해주세요!', style : TextStyle(fontSize: 21.0, color: AppColor.SocdocBlue)),
          content: Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: TextField(
              onChanged: (value) {
                context = value as BuildContext;
              },
              decoration: InputDecoration(
                hintText: '새로운 닉네임 입력',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColor.SocdocBlue),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style : TextStyle(fontSize: 17.0, color: AppColor.SocdocBlue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style : TextStyle(fontSize: 17.0, color: AppColor.SocdocBlue)),
            ),
          ],
        );
      },
    );
  }

  Widget MyPageList(String text, icon) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 20.0),
          Text(text, style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget HospitalInfo(String name, String address, String img) {
    return Container(
      width: 200,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26, width: 0.5),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage(img), width: 200, height: 100, fit: BoxFit.cover),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold, color: AppColor.SocdocBlue)),
                  SizedBox(height: 5.0),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 15),
                      Expanded(child: Text(address, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: Colors.black54))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FavoriteHospital(){
    if(isLoading_favoriteHospital) return circularProgress();
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteHospital.length,
        itemBuilder: (context, index){
          var hospital = favoriteHospital[index];
          String hospitalName = hospital["name"];
          String hospitalAddress = hospital["address"];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: HospitalInfo(hospitalName, hospitalAddress, 'assets/hospital2.png'),
          );
        },
      ),
    );
  }

  Widget MyReviewList(){
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          myReview("흑석성모안과의원", "2023.09.01", "다 좋은데 줄이 너무 길어요..", "4.0", 'assets/hospital2.png'),
          SizedBox(height: 10.0),
          myReview("연세이비인후과", "2023.10.23", "간호사가 별로에요.", "3.0", 'assets/hospital3.png'),
        ],
      ),
    );
  }

  Widget myReview(String name, String date, String comment, String rate, String img) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                child: ClipOval(
                  child: Image(
                    image: AssetImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 17)),
                  SizedBox(height: 2.0),
                  Text(date, style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              Spacer(),
              Column(
                children: [
                  Icon(Icons.star_rounded, color: Colors.amberAccent),
                  Text(rate),
                ],
              ),
              SizedBox(width: 10.0),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            child: Container(
              width: 300,
              height: 70,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.SocdocBlue, width: 0.5),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 5.0),
                    child: Text(comment, style: TextStyle(fontSize: 15, color: AppColor.SocdocBlue)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget BuildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _showLogoutDialog(SocdocAppState socdocApp, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('정말 로그아웃 하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                _tryFirebaseLogout(socdocApp);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteUserDialog(SocdocAppState socdocApp, BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text('정말 탈퇴 하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                _tryFirebaseDeleteUser(socdocApp);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _tryFirebaseLogout(SocdocAppState socdocApp) async {
    if (await tryLogout()) {
      socdocApp.setState(() {
        socdocApp.isLoggedIn = false;
      });
    }
  }

  void _tryFirebaseDeleteUser(SocdocAppState socdocApp) async {
    if (await tryDeleteUser()) {
      socdocApp.setState(() {
        socdocApp.isLoggedIn = false;
      });
    }
  }
}