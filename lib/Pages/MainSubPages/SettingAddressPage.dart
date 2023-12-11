import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:socdoc_flutter/Utils/AuthUtil.dart';

class SettingAddressPage extends StatefulWidget {
  final Function()? onAddressUpdate;

  const SettingAddressPage({Key? key, this.onAddressUpdate}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingAddressPageState();
}

class _SettingAddressPageState extends State<SettingAddressPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  var curAddress1 = "서울특별시";
  var curAddress2 = "동작구";

  @override
  void initState() {
    super.initState();

    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SettingAddressPage'),
        actions: [
          IconButton(
            onPressed: (){
              _uploadData();
            }, icon: const Icon(Icons.check))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              "지도를 움직여 위치를 선택해주세요.",
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 5.0),
            CurrentAddress(curAddress1: curAddress1, curAddress2: curAddress2),
            const SizedBox(height: 10.0),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: const CameraPosition(
                  target: LatLng(37.4905987, 126.9441426),
                  zoom: 17,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
                onCameraIdle: () async {
                  GoogleMapController controller = await _controller.future;
                  var latlng = await controller.getVisibleRegion();
                  var lat = (latlng.northeast.latitude + latlng.southwest.latitude) / 2;
                  var lng = (latlng.northeast.longitude + latlng.southwest.longitude) / 2;

                  http.get(Uri.parse("https://dapi.kakao.com/v2/local/geo/coord2regioncode.JSON?x=${lng}&y=${lat}"),
                    headers: {
                      "Authorization": "KakaoAK ${dotenv.env['KAKAO_API_KEY']}"
                  }).then((res) {
                    var resJson = jsonDecode(res.body);

                    setState(() {
                      curAddress1 = resJson["documents"][0]["region_1depth_name"];
                      curAddress2 = resJson["documents"][0]["region_2depth_name"];
                    });
                  });
                },
              )
            )
          ],
        ),
      )
    );
  }

  Future<void> _uploadData() async {
    http.put(Uri.parse("https://socdoc.dev-lr.com/api/user/update/address"),
      headers: {
        "content-type": "application/json"
      },
      body: jsonEncode({
        "address1": curAddress1,
        "address2": curAddress2,
        "userId": getUserID(context)
      })).then((res){
        if(res.statusCode == 200) {
          widget.onAddressUpdate?.call();
          Navigator.pop(context);
        }
    });
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

class CurrentAddress extends StatefulWidget {
  const CurrentAddress({super.key, required this.curAddress1, required this.curAddress2});

  final String curAddress1;
  final String curAddress2;

  @override
  State<StatefulWidget> createState() => _CurrentAddressState();
}

class _CurrentAddressState extends State<CurrentAddress> {
  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.curAddress1} ${widget.curAddress2}",
      style: const TextStyle(fontSize: 20.0),
    );
  }
}