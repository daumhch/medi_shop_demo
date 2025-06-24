import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' show LatLng;

const String appName = 'Medi Shop Demo';

//서울시 종로구 임의 위치
const double initLat = 37.57037778;
const double initLng = 126.9816417;

// riverpod을 통해 공유되는 현재 위치 정보
final pvLocation = StateProvider<LatLng>((ref) => LatLng(initLat, initLng));

// 서비스 실행 기기(앱, 웹)의 위치 정보 권한 얻기
Future<void> getPermission() async {
  Location location = Location();

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }

  permissionGranted = await location.requestPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
}

// 서비스 실행 기기(앱, 웹)의 위치 정보 얻기
Future<LocationData> getLocationData() async {
  Location location = Location();
  LocationData locationData = await location.getLocation();
  return locationData;
}

List<List<dynamic>> totalListData = [];
final pvShopList = StateProvider<List>((ref) => []);

//위도 경도를 km로 바꾸기
// = 1 / 109.958489129649955;
// = 0.0090943410364698544908800084221;
//                    35.170180477975
//const double unitLat = 0.009094341036 / 4; //1 = 1km, 2 = 500m

// = 1 / 88.74;
// = 0.01126887536623844940274960558936;
//                   126.888059043976
//const double unitLng = 0.011268875366 / 4;

// assets에 있는 csv 파일 읽어서 total list로 바꾸기
Future<void> getTotalList() async {
  final rawData = await rootBundle.loadString('assets/temp_list.csv');
  totalListData = const CsvToListConverter().convert(rawData);
  totalListData.removeAt(0); // csv 첫 줄에 있는 제목 제거
}

// total list에서 위치 주변 범위에 있는 list 필터링하기
Future<List> getShopList(double latitude, double longitude, double zoom) async {
  List<List<dynamic>> shopList = [];
  double unitLat = -0.0027283023 * zoom + 0.0509283098; // zoom to lat
  double unitLng = -0.0033806626 * zoom + 0.0631057020; // zoom to lng

  for (int i = 0; i < totalListData.length; i++) {
    var tempShop = totalListData[i];
    double tempLat = tempShop[1];
    double tempLng = tempShop[2];
    if ((latitude - unitLat < tempLat && tempLat < latitude + unitLat) &&
        (longitude - unitLng < tempLng && tempLng < longitude + unitLng)) {
      shopList.add(tempShop);
    }
  }
  return shopList;
}

//입력받은 list에 따라 마커List로 반환
List<Marker> makeTextMarkers(List<dynamic> list) {
  List<Marker> tempList = [];

  //for (var element in list)
  for (int i = 0; i < list.length; i++) {
    tempList.add(
      Marker(
        //point: LatLng(element[1], element[2]),
        point: LatLng(list[i][1], list[i][2]),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
            border: Border.all(),
          ),
          child: Text(
            '${list[i][0]}',
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        height: 20,
        width: 80,
      ),
    );
  }
  return tempList;
}
