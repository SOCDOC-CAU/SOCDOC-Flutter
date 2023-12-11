import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:label_marker/label_marker.dart';
import 'package:socdoc_flutter/Pages/DetailPage.dart';
import 'package:socdoc_flutter/Utils/Color.dart' as SocdocAppColor;

import 'package:socdoc_flutter/style.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:socdoc_flutter/Utils/HospitalTypes.dart';

bool isButtonPressed = false;
bool isHospitalSelected = false;
int pageIdx = 1;
String? selectedValue1 = "0";
String selectedHospitalID = "D000";
String selectedHospitalKO = '전체';
String curAddress1 = "서울특별시";
String curAddress2 = "동작구";

Set<Marker> mapMarkers = {};
const List<String> SortingCriteria = ['별점순', '이름순'];

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Expanded(
          child: Stack(
            children:[
              MapView(),
              MapBottomSheet(),
            ]
          ),
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
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      markers: mapMarkers,
      initialCameraPosition: initCoord,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onCameraIdle: () async {
        GoogleMapController controller = await _controller.future;
        var latlng = await controller.getVisibleRegion();
        var lat = (latlng.northeast.latitude + latlng.southwest.latitude) / 2;
        var lng = (latlng.northeast.longitude + latlng.southwest.longitude) / 2;

        http.get(Uri.parse("https://dapi.kakao.com/v2/local/geo/coord2regioncode.JSON?x=$lng&y=$lat"),
            headers: {
              "Authorization": "KakaoAK ${dotenv.env['KAKAO_API_KEY']}"
            }).then((res) {
          var resJson = jsonDecode(res.body);

          setState(() {
            curAddress1 = resJson["documents"][0]["region_1depth_name"];
            curAddress2 = resJson["documents"][0]["region_2depth_name"];
          });
        });
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
  bool isHospitalSpecialtyPressed = false;
  bool isSelected =  false;
  String? selectedHospitalName;

  List<Widget> hospitalItemList = [];

  @override
  void initState() {
    super.initState();

    isButtonPressed = false;
    isHospitalSelected = false;
    pageIdx = 1;
    selectedValue1 = SortingCriteria[0];
    selectedHospitalID = "D000";
    selectedHospitalKO = '전체';
    curAddress1 = "서울특별시";
    curAddress2 = "동작구";

    getHospitalList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        DraggableScrollableSheet(
          initialChildSize: 0.14,
          minChildSize: 0.14,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
                  color: Colors.white),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 70,
                      height: 4.5,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:25.0, right:25.0, top:20.0, bottom: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right:20.0),
                                child: DropDownButton1(),
                              ),
                              CustomDropDown(updater: getHospitalList),
                            ],
                          ),
                          const SizedBox(height: 15),
                          hospitalItemList.isNotEmpty
                              ? Column(children: hospitalItemList)
                              : Column(mainAxisSize: MainAxisSize.max, children: [circularProgress()],),
                          const SizedBox(height: 15),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(80, 45),
                              backgroundColor: AppColor.logo,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: AppColor.logo,
                                  width: 1.0,
                                ),
                              ),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            onPressed: (){
                              pageIdx++;
                              getHospitalList();
                            },
                            child: const Text("더보기"))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    );
  }

  void getHospitalList() {
    setState(() {
      hospitalItemList.clear();
      http.get(Uri.parse("https://socdoc.dev-lr.com/api/hospital/list${selectedHospitalID != "D000" ? '/$selectedHospitalID' : ''}"
          "?address1=$curAddress1&address2=$curAddress2"
          "&pageNum=$pageIdx&sortType=${selectedValue1 == "별점순" ? 0 : 1}"))
          .then((value){
        var tmp = jsonDecode(utf8.decode(value.bodyBytes));
        setState(() {
          tmp["data"].forEach((item){
            hospitalItemList.add(HospitalCard(item["name"], item["address"], item["hpid"], item["rating"]!.toString()));
            mapMarkers.addLabelMarker(LabelMarker(
              label: item["name"],
              markerId: MarkerId(item["name"]),
              position: LatLng(item["latitude"], item["longitude"]),
              backgroundColor: SocdocAppColor.AppColor.SocdocBlue,
            ));
          });
        });
      });
    });
  }

  Widget HospitalCard(String name, String address, String hospitalID, String rating) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailPage(hpid: hospitalID)));
      },
      child: Column(
        children: [
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
                    padding: const EdgeInsets.only(left: 12.0,right:12.0, top:12.0, bottom:2.0 ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: const Image(
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
                        Expanded(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColor.logo),
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Icon(Icons.star_rounded, color: Colors.amberAccent),
                            ),
                            Text(rating),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(left: 16.0, top: 5.0), child: Icon(Icons.location_on)),
                      const Padding(padding: EdgeInsets.only(left: 10.0)),
                      Expanded(
                        child: Text(
                          address,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget DropDownButton1() {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        items: SortingCriteria
            .map((String item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        )).toList(),
        value: selectedValue1,
        onChanged: (value) {
          setState(() {
            pageIdx = 1;
            selectedValue1 = value;
            getHospitalList();
          });
        },
        selectedItemBuilder: (BuildContext context) {
          return SortingCriteria.map<Widget>((String item) {
            return Center(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColor.logo,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList();
        },
        buttonStyleData: ButtonStyleData(
          height: 45,
          width: 100,
          padding: const EdgeInsets.only(left: 12, right: 6.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.logo,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.expand_more_rounded,
            color: AppColor.logo,
          ),
          iconSize: 26,
          iconEnabledColor: selectedValue1 != null ? AppColor.logo : AppColor.logo,
          iconDisabledColor: Colors.grey,
          openMenuIcon: Icon(
              Icons.expand_less_rounded,
              color: AppColor.logo),
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

  Widget circularProgress(){
    return Center(
      child: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator()
          )
      ),
    );
  }
}

class CustomDropDown extends StatefulWidget {
  const CustomDropDown({
    super.key,
    required this.updater
  });

  final Function updater;

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
            offset: const Offset(-145.0, 0),
            child: Align(
              alignment: AlignmentDirectional.topCenter,
              child: MenuWidget(
                width: _buttonWidth,
                onItemSelected: (selectedItem) {
                  setState(() {
                    pageIdx = 1;
                    selectedHospitalKO = selectedItem;
                    _tooltipController.toggle();
                    isButtonPressed = true;
                    widget.updater();
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
            minimumSize: const Size(108, 45),
            padding: const EdgeInsets.only(left: 16, right: 6),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: AppColor.logo,
                width: 1.0,
              ),
            ),
            foregroundColor: AppColor.logo,
            elevation: 0,
          ),
          child: Row(
            children: [
              Text(
                selectedHospitalKO.isEmpty ? '전체' : selectedHospitalKO,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                isButtonPressed ? Icons.expand_less_rounded : Icons.expand_more_rounded,
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
    return SizedBox(
      height: 610.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
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
                          selectedHospitalID = hospitalItem.id;
                          selectedHospitalKO = hospitalItem.ko;
                          widget.onItemSelected?.call(selectedHospitalKO);
                          isHospitalSelected = true;
                        });
                      },
                      leading: SizedBox(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
