import 'package:flutter/material.dart';
import 'package:socdoc_flutter/Utils/Color.dart';
import 'package:socdoc_flutter/Pages/ReviewPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class DetailPage extends StatefulWidget {
  const DetailPage({Key? key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Map<String, dynamic>? hospitalDetail;

  @override
  void initState() {
    super.initState();
    fetchHospitalDetail();
  }

  Future<void> fetchHospitalDetail() async {
    final response = await http.get(
      Uri.parse("https://socdoc.dev-lr.com/api/hospital/detail"),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        hospitalDetail = data;
      });
    } else {
      print("에러 발생: ${response.statusCode}");
      print("에러 내용: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final edgeInsets = EdgeInsets.only(left: 16.0, top: 5.0);
    final detailTextStyle = TextStyle(fontSize: 16);
    final detailPharmacyStyle = TextStyle(fontSize: 17, fontWeight: FontWeight.bold);
    final titlePharmacy = TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColor.SocdocBlue);

    Widget detailHospital(IconData icon, String text, {List<String>? dropdownItems}) {
      return Row(
        children: [
          Padding(padding: edgeInsets, child: Icon(icon)),
          Padding(padding: EdgeInsets.only(left: 10.0, top: 5.0)),
          Text(text, style: detailTextStyle),
          if (dropdownItems != null)
            DropdownButton<String>(
              value: dropdownItems[0],
              icon: const Icon(Icons.arrow_drop_down),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onChanged: (String? newValue) {
              },
              items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
        ],
      );
    }

    Widget detailPharmacy(String text) {
      return Row(
        children: [
          Padding(padding: edgeInsets, child: Icon(Icons.location_on)),
          Padding(padding: EdgeInsets.only(left: 10.0)),
          Text(text, style: detailPharmacyStyle),
        ],
      );
    }

    //주변 약국 tabview
    Widget nearbyPharmacy(String text) {
      return SizedBox(
        height: 110, width: 350,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 10.0,
          surfaceTintColor: Colors.transparent,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 5.0),
                child: Text(text, style: titlePharmacy),
              ),
              detailPharmacy("동작구 상도동 4길 36"),
            ],
          ),
        ),
      );
    }
    Widget reviewTab() {
      return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Text("전체 평점", style: detailTextStyle),
                SizedBox(width: 10.0),
                Icon(Icons.star_rounded, color: Colors.amberAccent),
                Text("4.3", style: detailTextStyle),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
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
                SizedBox(width: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DEV.LR", style: TextStyle(fontSize: 18)),
                    Text("2023.09.23"),
                  ],
                ),
                SizedBox(width: 200.0),
                Column(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.amberAccent),
                    Text("5.0"),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Container(
              alignment: Alignment.centerRight,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                color: AppColor.SocdocBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, top: 15.0, bottom: 5.0),
                      child: Text("줄이 너무 길어요", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                    SizedBox(
                      height: 30, width: 320,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: 400,
                height: 200,
                child: Image(
                  image: AssetImage('assets/hospital3.png'),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "서울성모안과의원",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(width: 65.0),
                        Column(
                          children: [
                            Icon(Icons.favorite_rounded, color: Colors.pink, size: 30.0),
                            Text('3'),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    detailHospital(Icons.call, "02-1234-5678"),
                    detailHospital(Icons.location_on, "동작구 상도동 4길 36"),
                    detailHospital(Icons.subway, "상도역 5번 출구"),
                    detailHospital(
                      Icons.alarm,
                      "진료 시간   ",
                      dropdownItems: ["(월) 09:00 ~ 19:00", "(화) 09:00 ~ 19:00", "(수) 09:00 ~ 19:00", "(목) 09:00 ~ 19:00", "(금) 09:00 ~ 19:00", "(토) 09:00 ~ 19:00", "(일) 09:00 ~ 19:00"],
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
                      body: reviewTab(),
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReviewPage()));
                        },
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.rate_review_outlined,
                          color: AppColor.SocdocBlue,
                        ),
                      ),
                    ),

                    // 두 번째 탭(주변 약국)
                    Tab(child: nearbyPharmacy("상도 온누리 약국")),
                  ],
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
