import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:socdoc_flutter/Utils/AuthUtil.dart';
import 'package:socdoc_flutter/Utils/Color.dart';
import 'package:socdoc_flutter/Pages/ReviewPage.dart';

import "package:http/http.dart" as http;


class DetailPage extends StatefulWidget {
  const DetailPage({required this.hpid, Key? key}) : super(key: key);

  final String hpid;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final edgeInsets = EdgeInsets.only(left: 16.0, top: 5.0);
  final detailTextStyle = TextStyle(fontSize: 16);
  final detailPharmacyStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
  final titlePharmacy = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.SocdocBlue);
  var hospitalDetail = null;
  String hpName = "";
  String hpId = "";
  var pharmacyDetail = null;
  var hospitalReview = null;
  bool isLoading_hospital = true;
  bool isLoading_pharmacy = true;
  bool isLoading_review = true;

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

  Widget detailHospital(IconData icon, String text, {List<dynamic>? dropdownItems}) {
    return Row(
      children: [
        Padding(padding: edgeInsets, child: Icon(icon, size: 23,)),
        const Padding(padding: EdgeInsets.only(left: 10.0, top: 5.0)),
        Text(text, style: detailTextStyle),
        if (dropdownItems != null)
          DropdownButton<String>(
            value: dropdownItems[0],
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: 25,
            elevation: 16,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            onChanged: (String? newValue) {
              setState(() {
                dropdownItems[0] = newValue!;
              });
            },
            items: dropdownItems.map<DropdownMenuItem<String>>((dynamic value) {
              return DropdownMenuItem<String>(
                value: value.toString(),
                child: Text(value),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<void> pharmacyInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/hospital/pharmacy?hospitalId=${widget.hpid}"))
        .then((value){
          print(pharmacyDetail);
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        pharmacyDetail = jsonDecode(tmp)["data"];
        print(value.body);
        print(pharmacyDetail);
        isLoading_pharmacy = false;
      });
    }).onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }

  Widget detailPharmacy(String name, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 5.0),
          child: Text(name, style: titlePharmacy),
          ),
        Row(
          children: [
            Padding(padding: edgeInsets, child: Icon(Icons.location_on)),
            const Padding(padding: EdgeInsets.only(left: 10.0)),
            Text(address, style: detailPharmacyStyle),
          ],
        ),
      ],
    );
  }

  Widget nearbyPharmacy(String name, String address) {
    return Column(
      children: [
        const SizedBox(height: 15.0),
        SizedBox(
          height: 100, width: 350,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 10.0,
            surfaceTintColor: Colors.transparent,
            color: Colors.white,
            child: detailPharmacy(name, address),
          ),
        ),
      ],
    );
  }

  Widget pharmacyList() {
    if (isLoading_pharmacy) {
      return circularProgress();
    } else if (pharmacyDetail != null) {
      return ListView.builder(
        itemCount: pharmacyDetail.length,
        itemBuilder: (context, index) {
          var pharmacy = pharmacyDetail[index];
          String pharmacyName = pharmacy["name"];
          String pharmacyAddress = pharmacy["address"];

          return nearbyPharmacy(pharmacyName, pharmacyAddress);
        },
      );
    } else {
      return const Text("데이터를 불러오는 중에 오류가 발생했습니다.");
    }
  }

  Future<void> reviewInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/review/hospital?hospitalId=${widget.hpid}"))
        .then((value){
      setState(() {
        var tmp = utf8.decode(value.bodyBytes);
        hospitalReview = jsonDecode(tmp)["data"];
        print('리뷰 조회 성공 : ' + value.body);
        print(hospitalReview);
        isLoading_review = false;
      });
    }).onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }

  Widget reviewList() {
    if (isLoading_review) {
      return circularProgress();
    } else if (hospitalReview != null) {
      return ListView.builder(
        itemCount: hospitalReview.length,
        itemBuilder: (context, index) {
          var review = hospitalReview[index];
          String userName = review["name"];
          String reviewCreatedAt = review["createdAt"];
          String content = review["content"];
          String rating = review["rating"].toString();

          return reviewTab(userName, reviewCreatedAt, content, rating);
        },
      );
    } else {
      return const Text("데이터를 불러오는 중에 오류가 발생했습니다.");
    }
  }

  Widget reviewTab(userName, reviewCreatedAt, content, rating) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                child: ClipOval(
                  child: Image(
                    image: AssetImage('assets/user.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName, style: const TextStyle(fontSize: 18)),
                    Text(reviewCreatedAt, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 140.0),
              Column(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amberAccent),
                  Text(rating),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Container(
            alignment: Alignment.centerRight,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              color: AppColor.SocdocBlue,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 15.0, bottom: 5.0),
                      child: Text(content,
                          style: const TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    const SizedBox(
                      height: 30,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> likeHospital(String hospitalId, String userId) async{
    http.post(Uri.parse("https://socdoc.dev-lr.com/api/hospital/like"),
      headers: {
        "content-type": "application/json"
      },
      body: jsonEncode({
        "hospitalId": widget.hpid,
        "userId": getUserID(context)
      }));
  }

  Future<void> unlikeHospital(String hospitalId, String userId) async{
    http.delete(Uri.parse("https://socdoc.dev-lr.com/api/hospital/like"),
        headers: {
          "content-type": "application/json"
        },
        body: jsonEncode({
          "hospitalId": widget.hpid,
          "userId": getUserID(context)
        }));
  }

  Widget buildFavoriteIcon() {
    return GestureDetector(
      onTap: () async {
        if (hospitalDetail["userLiked"] == true) {
          print("unlike");
          await unlikeHospital(
            widget.hpid,
            getUserID(context),
          );
        } else {
          print("like");
          await likeHospital(
            widget.hpid,
            getUserID(context),
          );
        }

        setState(() {
          hospitalDetail["userLiked"] = !hospitalDetail["userLiked"];
          hospitalDetail["likeCount"] += (hospitalDetail["userLiked"] == true ? 1 : -1);
        });
      },
      child: hospitalDetail["userLiked"] == false
          ? const Icon(Icons.favorite_outline_rounded, color: Colors.pink, size: 30.0)
          : const Icon(Icons.favorite_rounded, color: Colors.pink, size: 30.0),
    );
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
        _LifecycleObserver(resumeCallback: () async => reviewInfo())
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reviewInfo();
    });
    hospitalDetailInfo();
    pharmacyInfo();
  }

  Future<void> hospitalDetailInfo() async {
    http.get(Uri.parse("https://socdoc.dev-lr.com/api/hospital/detail?hospitalId=${widget.hpid}&userId=${getUserID(context)}"))
      .then((value){
        setState(() {
          var tmp = utf8.decode(value.bodyBytes);
          hospitalDetail = jsonDecode(tmp)["data"];
          hpId = hospitalDetail["hpid"];
          hpName = hospitalDetail["name"];
          print(value.body);
          print(hospitalDetail);
          isLoading_hospital = false;
        });
    })
    .onError((error, stackTrace){
      print(error);
      print(stackTrace);
    });
  }

  Widget displayHospitalDetail(){
    if(isLoading_hospital) return circularProgress();
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: 400,
                  height: 200,
                  child: const Image(
                    image: AssetImage('assets/hospital3.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 25.0),
                          Container(
                            width: 300,
                            alignment: Alignment.center,
                            child: Text(
                              hospitalDetail["name"],
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              buildFavoriteIcon(),
                              Text(hospitalDetail["likeCount"].toString()),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      detailHospital(Icons.call, hospitalDetail["phone"]),
                      detailHospital(Icons.location_on, hospitalDetail["address"]),
                      detailHospital(Icons.subway, hospitalDetail["description"] == null ? "정보가 없습니다." : hospitalDetail["description"]),
                      detailHospital(
                        Icons.alarm,
                        "진료 시간   ",
                        dropdownItems: hospitalDetail["time"].map((e) => e.toString()).toList(),
                      ),
                    ],
                  ),
                ),
                const TabBar(tabs: [
                  Tab(child: Text("리뷰", style: TextStyle(
                      fontSize: 18, color: AppColor.SocdocBlue),
                  ),
                  ),
                  Tab(child: Text("주변 약국", style: TextStyle(
                      fontSize: 18, color: AppColor.SocdocBlue),
                  ),
                  ),
                ]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // 첫 번째 탭(리뷰)
                      Scaffold(
                        body: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text("전체 평점", style: detailTextStyle),
                                  const SizedBox(width: 10.0),
                                  const Icon(Icons.star_rounded, color: Colors.amberAccent),
                                  Text(hospitalDetail["rating"].toString(), style: detailTextStyle),
                                ],
                              ),
                              Expanded(
                                  child: reviewList()
                              ),
                            ],
                          ),
                        ),
                        floatingActionButton: FloatingActionButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReviewPage(hospitalID: hpId, hospitalName: hpName)));
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.rate_review_outlined,
                            color: AppColor.SocdocBlue,
                          ),
                        ),
                      ),

                      // 두 번째 탭(주변 약국)
                      Tab(child:
                      pharmacyList()
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return displayHospitalDetail();
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
