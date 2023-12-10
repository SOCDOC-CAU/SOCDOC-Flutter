import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:socdoc_flutter/Pages/DetailPage.dart';
import 'package:socdoc_flutter/style.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socdoc_flutter/Utils/HospitalTypes.dart';

bool isButtonPressed = false;
bool isHospitalSelected = false;
final List<String> SortingCriteria = [
  '별점순',
  '이름순',
];
String? selectedValue1;
String selectedHospitalKO = '';
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
              child: const Text("Detail Page"),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailPage(hpid: "A1100005")));
              }
            ),
            Expanded(
              child: Stack(
                children:[
                  MapView(),
                 MapBottomSheet(),
                ]

              ),
            )],
        )
      )
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition initCoord = CameraPosition(
    target: LatLng(37.4905987, 126.9441426),
    zoom: 17,
  );

  @override
  Widget build(BuildContext context) {
    _determinePosition();

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: initCoord,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      }
    );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    await Geolocator.getCurrentPosition().then((cur) => {
      _moveCamera(cur.latitude, cur.longitude)
    });
  }

  Future<void> _moveCamera(lat, lng) async {
    CameraPosition newCoord = CameraPosition(
      target: LatLng(lat, lng),
      zoom: 17,
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCoord));
  }
}


class MapBottomSheet extends StatefulWidget {
  const MapBottomSheet({super.key});

  @override
  State<MapBottomSheet> createState() => _MapBottomSheetState();
}
class _MapBottomSheetState extends State<MapBottomSheet> {


  IconData arrowIcon = Icons.expand_more;
  bool isDropdownOpened = false;
  bool isSelected =  false;
  String? selectedHospitalName; //여기다가 병원 진료과목 저장해두었습니다
  bool isHospitalSpecialtyPressed = false;

  @override
  void initState() {
    super.initState();
    isButtonPressed = true;
    selectedValue1 = SortingCriteria[0];
  }

  @override
  Widget build(BuildContext context) {
    final edgeInsets = EdgeInsets.only(left: 16.0, top: 5.0);
    final detailHospitalStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    final titleHospital = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColor.logo);

    //병원 미리보기 카드
    //-> 카드에서 주소
    Widget HospitalAddress(String text) {
      return Row(
        children: [
          Padding(padding: edgeInsets, child: Icon(Icons.location_on)),
          Padding(padding: EdgeInsets.only(left: 10.0)),
          Text(text, style: detailHospitalStyle),
        ],
      );
    }
    Widget HospitalCard(String text) {
      return
        SizedBox(
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
                          Text("5.0"),
                        ],
                      ),
                    ],
                  ),
                ),
                HospitalAddress("동작구 상도동 4길 36"),
              ],
            ),
          ),
        );
    }
    //병원 미리보기 카드 끝
    Widget DropDownButton1() {
      return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          items: SortingCriteria
              .map((String item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ))
              .toList(),
          value: selectedValue1,
          onChanged: (value) {
            setState(() {
              selectedValue1 = value;
            });
          },
          selectedItemBuilder: (BuildContext context) {
            return
              SortingCriteria.map<Widget>((String item) {
                return Container(
                  child: Center(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // 버튼에 표시되는 선택된 항목의 글자 색을 흰색으로 설정
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList();
          },
          //버튼 layout
          buttonStyleData: ButtonStyleData(
            height: 45,
            width: 100,
            padding: const EdgeInsets.only(left: 12, right: 6.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.logo,
                width: 1.0, // 테두리 너비 조절
              ),
              borderRadius: BorderRadius.circular(20),
              color: selectedValue1 != null ? AppColor.logo : Colors.white ,
            ),
          ),

          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.expand_more,
              color: selectedValue1 != null ? Colors.white : AppColor.logo  ,
            ),
            iconSize: 26,
            iconEnabledColor: selectedValue1 != null ? Colors.white : AppColor.logo,
            iconDisabledColor: Colors.grey,
            openMenuIcon: Icon(
                Icons.expand_less,
                color: selectedValue1 != null ? Colors.white : AppColor.logo),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 100,
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.white,
            ),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 40,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      );
    }

    return Stack(
    children: [
        Container(
            color: Colors.white,
            child: Text("지도"),
    ),
    DraggableScrollableSheet(
    // 화면 비율로 높이 조정
        initialChildSize: 0.14,
        minChildSize: 0.14,
        maxChildSize: 0.8,
        builder: (BuildContext context, ScrollController scrollController) {
    return SingleChildScrollView(
        controller: scrollController,
        child: Container(
           height: 1500,
           decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),

                topRight: Radius.circular(20)),
                color: Colors.white,
           ),
                child:  SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 70,
                        height: 4.5,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:25.0, right:25.0, top:20.0 ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right:20.0),
                                  child: DropDownButton1(),
                                ),
                                CustomDropDown(),
                              ],
                            ),
                            SizedBox(height: 15),
                            Column(
                              children: [
                                HospitalCard('서울연세이비인후과'),
                                HospitalCard('서울연세이비인후과'),
                                HospitalCard('서울연세이비인후과'),
                                HospitalCard('서울연세이비인후과'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
      ),
      ),
    ),);
    },
    )
    ],
    );


  }
}
class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => CustomDropDownState();
}
class CustomDropDownState extends State<CustomDropDown> {

  final _link = LayerLink();
  double? _buttonWidth;
  final OverlayPortalController _tooltipController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {

    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _tooltipController,
        overlayChildBuilder: (BuildContext context) {
          return CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            offset: Offset(-145.0, 0),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: MenuWidget(
                width: _buttonWidth,
                onItemSelected: (selectedItem) {
                  setState(() {
                    selectedHospitalKO = selectedItem;
                    _tooltipController.toggle();
                    isButtonPressed = true;
                  });
                },
              ),
            ),
          );
        },
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _tooltipController.toggle();
              isButtonPressed = !isButtonPressed;
            });
          },
          style: ElevatedButton.styleFrom(
            minimumSize: Size(108, 45),
            padding: const EdgeInsets.only(left: 16, right: 6),
            backgroundColor: AppColor.logo,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColor.logo,
                width: 1.0,
              ),
            ),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: Row(
            children: [
              Text(
                selectedHospitalKO.isEmpty ? '전체' : selectedHospitalKO,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                isButtonPressed ? Icons.expand_more : Icons.expand_less,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuWidget extends StatefulWidget {
  const MenuWidget({
    Key? key,
    this.width,
    this.onItemSelected,
  }) : super(key: key);

  final double? width;
  final ValueChanged<String>? onItemSelected;

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 610.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: GridView.builder(
              itemCount: HospitalTypes
                  .where((item) => item.ko.isNotEmpty)
                  .length,
              itemBuilder: (context, index) {
                HospitalItem hospitalItem = HospitalTypes
                    .where((item) => item.ko.isNotEmpty)
                    .elementAt(index);

                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: index >=
                            HospitalTypes.where((item) => item.ko.isNotEmpty)
                                .length -
                                1
                            ? Colors.transparent
                            : AppColor.GridLineStyle,
                        width: 2.0,
                      ),
                      right: BorderSide(
                        color: index.isEven
                            ? AppColor.GridLineStyle
                            : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ListTile(
                      tileColor: Colors.white,
                      onTap: () {
                        setState(() {
                          selectedHospitalKO = hospitalItem.ko;
                          widget.onItemSelected?.call(selectedHospitalKO); // 추가: 선택된 아이템 전달
                          isHospitalSelected = true;
                          print(selectedHospitalKO);
                        });
                      },
                      leading: Container(
                        width: 45,
                        height: 45,
                        child: Image.asset(
                          'assets/hospital/${hospitalItem.num}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        hospitalItem.ko,
                        key: Key('text_$index'),
                        style: TextStyle(
                          color: selectedHospitalKO == hospitalItem.ko
                              ? AppColor.GridTextStyleOnPressed
                              : AppColor.GridTextStyle,
                          fontWeight: selectedHospitalKO == hospitalItem.ko
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
